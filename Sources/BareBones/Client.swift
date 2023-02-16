import Foundation

public class HttpClient {
    private let requestBuilder: RequestBuilder
    
    public var httpHeaders: [String: String] = [
        "Content-Type": "application/json"
    ]
    
    public init(baseUrl: String) {
        requestBuilder = RequestBuilder(baseUrl: baseUrl)
    }
    
    public func data(
        via method: HttpMethod,
        to path: String = "",
        with content: RequestContent = .empty
    ) async -> Result<Data, ApiError> {
        do {
            let request = try requestBuilder.buildRequest(
                via: method,
                to: path,
                with: content,
                httpHeaders: httpHeaders
            )
            if let mocked = HttpClient.intercept(request) {
                return mocked
            }
            
            return await withCheckedContinuation { continuation in
                URLSession.shared.dataTask(with: request) { data, _, error in
                    guard error == nil else {
                        continuation.resume(returning: .failure(.requestFailed))
                        return
                    }
                    guard let data else {
                        continuation.resume(returning: .failure(.noData))
                        return
                    }
                    continuation.resume(returning: .success(data))
                }
                .resume()
            }
        } catch {
            return .failure(ApiError.malformedUrl)
        }
    }
    
    private func handle<T: Decodable>(responseData data: Data) -> Result<T, ApiError> {
        do {
            let result = try JSONDecoder().decode(T.self, from: data)
            return .success(result)
        } catch let error {
            print("\(Date()) [BareBones] Decoding failed! \(error)")
            return .failure(.decodingFailed)
        }
    }
}

public extension HttpClient {
    func get<T: Decodable>(from path: String = "", with params: [String: Any]=[:]) async -> Result<T, ApiError> {
        await run(via: .get, to: path, with: .url(params: params))
    }
    
    func getData(from path: String = "", with params: [String: Any]=[:]) async -> Result<Data, ApiError> {
        await data(via: .get, to: path, with: .url(params: params))
    }
    
    func post<T: Decodable>(to path: String = "", with content: any Encodable) async -> Result<T, ApiError> {
        await run(via: .post, to: path, with: .body(body: content))
    }
    
    func put<T: Decodable>(to path: String = "", with content: any Encodable) async -> Result<T, ApiError> {
        await run(via: .put, to: path, with: .body(body: content))
    }
}

private extension HttpClient {
    func run<T: Decodable>(
        via method: HttpMethod,
        to path: String = "",
        with content: RequestContent = .empty
    ) async -> Result<T, ApiError> {
        let response = await data(via: method, to: path, with: content)
        switch response {
        case .success(let data): return handle(responseData: data)
        case .failure(let error): return .failure(error)
        }
    }
}
