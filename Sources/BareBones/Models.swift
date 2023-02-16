public enum ApiError: Error {
    case decodingFailed
    case invalidRequestBody
    case malformedUrl
    case noData
    case requestFailed
}

public enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
    case post = "POST"
}

public enum RequestContent {
    case url(params: [String: Any])
    case body(body: any Encodable)
    case empty
}
