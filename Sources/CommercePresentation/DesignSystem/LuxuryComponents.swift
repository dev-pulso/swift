#if os(iOS)
import SwiftUI

@MainActor
struct LuxuryButton: View {
    let title: String
    var secondary = false
    var loading = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if loading { ProgressView().tint(secondary ? LuxuryTheme.ink : LuxuryTheme.surface) }
                Text(title).font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(secondary ? LuxuryTheme.ink : LuxuryTheme.surface)
            .background(secondary ? LuxuryTheme.surface : LuxuryTheme.ink)
            .overlay(Rectangle().stroke(LuxuryTheme.ink, lineWidth: 1))
        }
        .buttonStyle(.plain).disabled(loading)
    }
}

@MainActor
struct LuxuryCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(LuxuryTheme.surface)
            .overlay(Rectangle().stroke(LuxuryTheme.border, lineWidth: 1))
    }
}

@MainActor
struct LuxuryLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased()).font(.caption.weight(.semibold)).tracking(1.2)
            .foregroundStyle(LuxuryTheme.muted)
    }
}

@MainActor
struct LuxuryTextField: View {
    let title: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LuxuryLabel(text: title)
            TextField(title, text: $text).textFieldStyle(.plain).padding(14)
                .background(LuxuryTheme.surface)
                .overlay(Rectangle().stroke(LuxuryTheme.border, lineWidth: 1))
                .accessibilityLabel(title)
        }
    }
}

@MainActor
struct LuxurySearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").accessibilityHidden(true)
            TextField("Buscar", text: $text).autocorrectionDisabled()
                .accessibilityLabel("Buscar en esta sección")
        }.padding(16).background(LuxuryTheme.surface)
            .overlay(Rectangle().stroke(LuxuryTheme.border, lineWidth: 1))
    }
}

@MainActor
struct LuxuryMetricCard: View {
    let title: String
    let value: String
    var body: some View {
        LuxuryCard {
            VStack(alignment: .leading, spacing: 16) {
                LuxuryLabel(text: title)
                Text(value).font(.title2.weight(.semibold)).monospacedDigit()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }.accessibilityElement(children: .combine)
    }
}

@MainActor
struct LuxuryBadge: View {
    let text: String
    var body: some View {
        Text(text).font(.caption.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 6)
            .background(LuxuryTheme.canvas).overlay(Rectangle().stroke(LuxuryTheme.border))
    }
}

@MainActor
struct LuxuryEmptyState: View {
    let title: String
    let message: String
    var symbol = "square.stack.3d.up"
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: symbol).font(.largeTitle).accessibilityHidden(true)
            Text(title).font(.title2.weight(.semibold))
            Text(message).foregroundStyle(LuxuryTheme.muted)
        }.padding(.vertical, 32).frame(maxWidth: .infinity, alignment: .leading)
    }
}

@MainActor
struct LuxurySectionHeader: View {
    let title: String
    var body: some View { Text(title).font(.title3.weight(.semibold)).padding(.top, 12) }
}

@MainActor
struct LuxuryAvatar: View {
    let name: String
    var body: some View {
        Text(name.split(separator: " ").prefix(2).compactMap { $0.first.map(String.init) }.joined())
            .font(.headline).frame(width: 48, height: 48)
            .foregroundStyle(LuxuryTheme.surface).background(LuxuryTheme.ink)
            .accessibilityHidden(true)
    }
}

@MainActor
struct LuxuryError: View {
    let message: String
    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .font(.callout).foregroundStyle(LuxuryTheme.danger)
            .accessibilityAddTraits(.updatesFrequently)
    }
}

#endif
