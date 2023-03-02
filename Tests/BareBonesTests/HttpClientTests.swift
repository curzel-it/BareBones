import Foundation
import XCTest

@testable import BareBones

final class HttpClientTests: XCTestCase {
    override func setUp() async throws {
        HttpClient.removeAllInterceptors()
    }
    
    func testCanDecodeObjectIfEverythingGoesFine() async {
        let expectedFruits = [Fruit(name: "Apple"), Fruit(name: "Banana"), Fruit(name: "Cherry")]
        
        HttpClient.add(interceptor: Interceptor(when: .always, return: expectedFruits))
        
        let api = HttpClient(baseUrl: testUrl, logResponses: true)
        let result: Result<[Fruit], Error> = await api.get(with: [:])
        
        switch result {
        case .success(let fruits): XCTAssertEqual(expectedFruits, fruits)
        case .failure: XCTAssert(false)
        }
    }
    
    func testThrowsErrorIfResponseCannotBeDecoded() async {
        let expectedFruits = [Fruit(name: "Apple"), Fruit(name: "Banana"), Fruit(name: "Cherry")]
        HttpClient.add(interceptor: Interceptor(when: .always, return: expectedFruits))
                
        let api = HttpClient(baseUrl: testUrl, logResponses: true)
        let result: Result<[Animal], Error> = await api.get(with: [:])
        
        switch result {
        case .success: XCTAssert(false)
        case .failure(let error): XCTAssertEqual(ApiError.decodingFailed, error as? ApiError)
        }
    }
    
    func testCanGetDatafromHtmlPage() async {
        let expectedData = "Hello World!".data(using: .utf8)!
        HttpClient.add(interceptor: Interceptor(when: .always, return: expectedData))
                
        let api = HttpClient(baseUrl: testUrl, logResponses: true)
        let result = await api.data(via: .get)
        
        switch result {
        case .success(let data): XCTAssertEqual(expectedData, data)
        case .failure: XCTAssert(false)
        }
    }
}

private let testUrl = "https://www.google.com"

private struct Fruit: Codable, Equatable {
    let name: String
}

private struct Animal: Codable, Equatable {
    let species: String
}

