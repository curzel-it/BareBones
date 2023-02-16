import Foundation

public struct InterceptorCondition {
    public static let always: InterceptorCondition = .condition { _ in true }
    
    public static func urlContains(_ token: String) -> InterceptorCondition {
        .condition { request in request.url?.absoluteString.contains(token) ?? false }
    }
    
    public static func condition(_ foo: @escaping (URLRequest) -> Bool) -> InterceptorCondition {
        InterceptorCondition(condition: foo)
    }
    
    private let condition: (URLRequest) -> Bool
    
    func matches(_ request: URLRequest) -> Bool {
        condition(request)
    }
}
