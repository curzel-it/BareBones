# BareBones

The simplest possible Swift library for handling HTTP requests:
1. Async/Await interface
1. Uses `Result`
1. Uses `Decodable`
1. Can get both `Data` and `Decodable` as result
1. Easy syntax 
1. Integrated mocking 

## Why?
I've written code like this at least two dozen times in my career, sometimes based on URLSession, sometimes on top of Alamofire, sometimes from scratch for a take-home coding interview...

I'm getting a bit tired of the last one especially, and so here it is, once and for all... 

Next time I will just add this Swift Package to my take-home assignment, along with this note! 😅

## Can I use it?
Sure! It might actually be a valid alternative if you need something light with basic mocking backed-in.

I use this in production in a couple of personal project, it works just fine.

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

### Get Data rather than a Decodable
```swift
let client = HttpClient(baseUrl: https://apps.apple.com/app/pipper/id1587335166)
let response = await client.data(via: .get)

switch response {
case .success(let data): // ...
case .failure(let error): // ...
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
