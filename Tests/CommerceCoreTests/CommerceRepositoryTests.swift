import XCTest
@testable import CommerceCore

final class CommerceRepositoryTests: XCTestCase {
    private func fixture() throws -> (LocalCommerceRepository, StoreScope, ProductVariant) {
        let seed = DemoData.make()
        let branch = try XCTUnwrap(seed.branches.first)
        let variant = try XCTUnwrap(seed.products.first?.variants.first)
        return (try LocalCommerceRepository(seed: seed),
                StoreScope(businessID: branch.businessID, branchID: branch.id), variant)
    }

    func testCheckoutUpdatesStockAndRetryDoesNotSellTwice() async throws {
        let (repository, scope, variant) = try fixture()
        let before = try await repository.data(in: scope)
        let request = CheckoutRequest(scope: scope, items: [.init(variantID: variant.id, quantity: 2)],
                                      sellerID: UUID(), paymentMethod: .cash)
        let sale = try await repository.checkout(request)
        let retry = try await repository.checkout(request)
        let after = try await repository.data(in: scope)
        XCTAssertEqual(sale.id, retry.id)
        XCTAssertEqual(after.sales.count, before.sales.count + 1)
        XCTAssertEqual(after.stock.first { $0.variantID == variant.id }?.quantity, 1)
        XCTAssertEqual(sale.total, variant.price * 2)
    }

    func testInsufficientStockRollsBackEntireCart() async throws {
        let (repository, scope, variant) = try fixture()
        let before = try await repository.data(in: scope)
        let second = try XCTUnwrap(before.products[1].variants.first)
        let request = CheckoutRequest(scope: scope, items: [
            .init(variantID: variant.id, quantity: 1), .init(variantID: second.id, quantity: 999)
        ], sellerID: UUID(), paymentMethod: .card)
        do { _ = try await repository.checkout(request); XCTFail("Expected insufficient stock") }
        catch { XCTAssertEqual(error as? CommerceError, .insufficientStock) }
        let after = try await repository.data(in: scope)
        XCTAssertEqual(before.stock, after.stock)
        XCTAssertEqual(before.sales.count, after.sales.count)
        XCTAssertEqual(before.movements.count, after.movements.count)
    }

    func testForeignBranchIsRejected() async throws {
        let (repository, scope, _) = try fixture()
        do {
            _ = try await repository.data(in: StoreScope(businessID: scope.businessID, branchID: UUID()))
            XCTFail("Expected invalid scope")
        } catch { XCTAssertEqual(error as? CommerceError, .invalidScope) }
    }

    func testNewBusinessStartsEmpty() async throws {
        let (repository, _, _) = try fixture()
        let scope = try await repository.createBusiness(Business(name: "Urban Shoes", kind: .shoes))
        let data = try await repository.data(in: scope)
        XCTAssertTrue(data.products.isEmpty)
        XCTAssertTrue(data.stock.isEmpty)
        XCTAssertTrue(data.sales.isEmpty)
        XCTAssertTrue(data.customers.isEmpty)
    }

    func testDuplicateSKUsAreRejectedCaseInsensitively() async throws {
        let (repository, scope, variant) = try fixture()
        let product = Product(businessID: scope.businessID, name: "Duplicado", variants: [
            ProductVariant(sku: variant.sku.lowercased(), price: 10, cost: 5)
        ])
        do { try await repository.saveProduct(product, in: scope); XCTFail("Expected duplicate SKU") }
        catch { XCTAssertEqual(error as? CommerceError, .duplicateSKU) }
    }

    func testPersistenceRoundTrip() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("store.json")
        let repository = try LocalCommerceRepository(fileURL: file)
        let scope = try await repository.createBusiness(Business(name: "Glow", kind: .makeup))
        let reopened = try LocalCommerceRepository(fileURL: file)
        let data = try await reopened.data(in: scope)
        XCTAssertEqual(data.business.name, "Glow")
    }

    func testDashboardHasSevenDaysIncludingZeroSales() async throws {
        let (repository, scope, _) = try fixture()
        let data = try await repository.data(in: scope)
        let summary = DashboardCalculator.calculate(data)
        XCTAssertEqual(summary.lastSevenDays.count, 7)
        XCTAssertEqual(summary.lowStockVariants, 1)
        XCTAssertEqual(summary.outOfStockVariants, 1)
    }

    func testDiscountAndTaxUseDecimalAmounts() async throws {
        var seed = DemoData.make()
        seed.businesses[0].taxRate = Decimal(string: "0.19")!
        let branch = try XCTUnwrap(seed.branches.first)
        let variant = try XCTUnwrap(seed.products.first?.variants.first)
        let scope = StoreScope(businessID: branch.businessID, branchID: branch.id)
        let repository = try LocalCommerceRepository(seed: seed)
        let sale = try await repository.checkout(CheckoutRequest(scope: scope,
            items: [.init(variantID: variant.id, quantity: 1)], discount: 20000,
            sellerID: UUID(), paymentMethod: .transfer))
        XCTAssertEqual(sale.subtotal, 580000)
        XCTAssertEqual(sale.tax, 106400)
        XCTAssertEqual(sale.total, 666400)
        XCTAssertEqual(sale.estimatedGrossProfit, 170000)
    }

    func testWriteFailureDoesNotPublishSaleOrStockChange() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let blocker = directory.appendingPathComponent("not-a-directory")
        try Data("block".utf8).write(to: blocker)
        let seed = DemoData.make()
        let branch = try XCTUnwrap(seed.branches.first)
        let variant = try XCTUnwrap(seed.products.first?.variants.first)
        let scope = StoreScope(businessID: branch.businessID, branchID: branch.id)
        let repository = try LocalCommerceRepository(seed: seed,
            fileURL: blocker.appendingPathComponent("store.json"))
        let before = try await repository.data(in: scope)
        do {
            _ = try await repository.checkout(CheckoutRequest(scope: scope,
                items: [.init(variantID: variant.id, quantity: 1)], sellerID: UUID(), paymentMethod: .cash))
            XCTFail("Expected persistence failure")
        } catch { /* The filesystem error must propagate. */ }
        let after = try await repository.data(in: scope)
        XCTAssertEqual(before.stock, after.stock)
        XCTAssertEqual(before.sales.count, after.sales.count)
        XCTAssertEqual(before.movements.count, after.movements.count)
    }

    func testCustomerCannotBeSavedInAnotherBusiness() async throws {
        let (repository, scope, _) = try fixture()
        let customer = Customer(businessID: UUID(), name: "Cliente ajeno")
        do { try await repository.saveCustomer(customer, in: scope); XCTFail("Expected tenant rejection") }
        catch { XCTAssertEqual(error as? CommerceError, .invalidCustomer) }
    }
}
