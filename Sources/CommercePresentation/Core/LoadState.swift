import Foundation

public enum LoadState<Value> {
    case idle
    case loading
    case empty
    case success(Value)
    case failure(String)
}
