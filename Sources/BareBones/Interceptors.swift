import Foundation

extension HttpClient {
    private static var interceptors: [Interceptor] = []
    
    public static func add(interceptor: Interceptor) {
        interceptors.append(interceptor)
    }
    
    public static func remove(interceptor: Interceptor) {
        interceptors.removeAll { $0.id == interceptor.id }
    }
    
    public static func removeAllInterceptors() {
        interceptors.removeAll()
    }
    
    static func intercept(_ request: URLRequest) -> Result<Data, Error>? {
        for interceptor in interceptors {
            if let result = interceptor.intercept(request) {
                return result
            }
        }
        return nil
    }
}

public struct Interceptor {
    let id: String = UUID().uuidString
    let condition: InterceptorCondition
    let response: Result<Data, Error>
    
    public init(
        when condition: InterceptorCondition,
        return response: Result<Data, Error>
    ) {
        self.condition = condition
        self.response = response
    }
    
    public init(
        when condition: InterceptorCondition,
        return response: any Encodable
    ) {
        let data = try? JSONEncoder().encode(response)
        self.init(when: condition, return: .success(data ?? Data()))
    }
    
    public init(
        when condition: InterceptorCondition,
        return data: Data
    ) {
        self.init(when: condition, return: .success(data))
    }
    
    public func intercept(_ request: URLRequest) -> Result<Data, Error>? {
        condition.matches(request) ? response : nil
    }
}
