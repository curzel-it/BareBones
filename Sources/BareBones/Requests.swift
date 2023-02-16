import Foundation

struct RequestBuilder {
    let baseUrl: String
    
    func buildRequest(
        via method: HttpMethod,
        to path: String = "",
        with content: RequestContent = .empty,
        httpHeaders: [String: String] = [:]
    ) throws -> URLRequest {
        let url = try requestUrl(to: path, given: content)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = try requestBody(from: content)
        request.allHTTPHeaderFields = httpHeaders
        return request
    }
    
    func requestUrl(to path: String, given content: RequestContent) throws -> URL {
        let urlString = "\(baseUrl)/\(path)\(query(for: content))"
        guard let url = URL(string: urlString) else {
            throw ApiError.malformedUrl
        }
        return url
    }
    
    func requestBody(from content: RequestContent) throws -> Data? {
        if case .body(let body) = content {
            do {
                return try JSONEncoder().encode(body)
            } catch let error {
                print("[HttpClient] Error encoding request body \(error)")
                throw ApiError.invalidRequestBody
            }
        }
        return nil
    }
    
    func query(for content: RequestContent) -> String {
        if case .url(let params) = content {
            let query = queryItems(for: params)
            return query.isEmpty ? "" : "?\(query)"
        } else {
            return ""
        }
    }
    
    func queryItems(for params: [String: Any]) -> String {
        var components = URLComponents()
        components.queryItems = params
            .sorted { $0.key < $1.key }
            .map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        return components.percentEncodedQuery ?? ""
    }
}
