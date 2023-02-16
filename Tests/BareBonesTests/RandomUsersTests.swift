import Foundation
import XCTest

@testable import BareBones

final class RandomUsersTests: XCTestCase {
    func testGetRandomUsers() async {
        let client = HttpClient(baseUrl: testUrl)
        let response: Result<RandomUsersResponse, ApiError> = await client.get(
            from: "api", with: ["results": 5]
        )
        switch response {
        case .success(let response): XCTAssertEqual(response.results.count, 5)
        case .failure: XCTAssert(false)
        }
    }
    
    func testGetRandomUsersViaApiClient() async {
        let api = RandomUsersApi()
        let response = await api.fetchUsers()
        switch response {
        case .success(let response): XCTAssertEqual(response.results.count, 5)
        case .failure: XCTAssert(false)
        }
    }
}

private let testUrl = "https://randomuser.me"

private class RandomUsersApi {
    private let client = HttpClient(baseUrl: testUrl)
    
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
