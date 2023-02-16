import Foundation

extension Optional {
    func unwrap() throws -> Wrapped {
        switch self {
        case .some(let wrapped): return wrapped
        case .none: throw OptionalError.unwrappingOptionalValue
        }
    }
}

enum OptionalError: Error {
    case unwrappingOptionalValue
}

extension Result {
    func unwrap() throws -> Success {
        switch self {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
}
