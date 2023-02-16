# BareBones

The simplest possible Swift library for handling HTTP requests:
1. Async/Await interface
1. Uses `Result`
1. Uses `Decodable`
1. Can get both `Data` and `Decodable` as result
1. Easy syntax 
1. Integrated mocking 

## Examples

### Drop-In URLSession replacement
This is taken directly from [this test case](https://github.com/curzel-it/BareBones/blob/main/Tests/BareBonesTests/RandomUsersTests.swift).
```swift
let client = HttpClient(baseUrl: {domain})
let response: Result<{DecodableResponse}, ApiError> = await client.get(from: {endpoint}, with: {params})

switch response {
case .success(let response): // Fetched and decoded, ready for use
case .failure: // Handle any error
}
```

### API Client
This is taken directly from [this test case](https://github.com/curzel-it/BareBones/blob/main/Tests/BareBonesTests/RandomUsersTests.swift).
```swift
func fetchRandomUsers() async {
    let api = RandomUsersApi()
    let response = await api.fetchUsers()
    switch response {
    case .success(let response): // Fetched and decoded, ready for use
    case .failure: // Handle any error
    }
}
    
private class RandomUsersApi {
    private let client = HttpClient(baseUrl: "https://randomuser.me")
    
    func fetchUsers() async -> Result<RandomUsersResponse, ApiError> {
        await client.get(from: "api", with: ["results": 5])
    }
}

private struct RandomUsersResponse: Codable {
    let results: [RandomUser]
}

private struct RandomUser: Codable {
    let gender: String?
    let name: RandomUserName
    let email: String?
}

private struct RandomUserName: Codable {
    let first: String?
    let last: String?
    let title: String?
}
```

### Mock response
This is taken directly from [this test case](https://github.com/curzel-it/BareBones/blob/main/Tests/BareBonesTests/InterceptorsTests.swift).
```swift    
let interceptor = Interceptor(when: .urlContains("google.com"), return: .failure(.noData))
HttpClient.add(interceptor: interceptor)
let client = HttpClient(baseUrl: "https://www.google.com")
let response = await client.data(via: .get)
XCTAssertEqual(.failure(.noData), response)
HttpClient.removeAllInterceptors()
```
