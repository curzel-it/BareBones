import Foundation
import XCTest
@testable import BareBones

final class InterceptorsTests: XCTestCase {
    override func setUp() async throws {
        HttpClient.removeAllInterceptors()
    }
    
    func testInterceptorsCanBeAdded() async throws {
        let testData = try "hello".data(using: .utf8).unwrap()
        let testInterceptor = Interceptor(when: .always, return: .success(testData))
        HttpClient.add(interceptor: testInterceptor)
        let client = HttpClient(baseUrl: "https://www.google.com")
        let response = await client.data(via: .get)
        let responseData = try response.unwrap()
        XCTAssertEqual(testData, responseData)
    }
    
    func testInterceptAlwaysGetsAnyRequests() async throws {
        let testData = try "hello".data(using: .utf8).unwrap()
        let testInterceptor = Interceptor(when: .always, return: .success(testData))
        HttpClient.add(interceptor: testInterceptor)
        let client = HttpClient(baseUrl: "https://www.google.com")
        
        let responseGet = await client.data(via: .get)
        XCTAssertEqual(testData, try responseGet.unwrap())
        
        let responsePost = await client.data(via: .post)
        XCTAssertEqual(testData, try responsePost.unwrap())
        
        let otherClient = HttpClient(baseUrl: "https://www.netflix.com")
        let otherResponse = await otherClient.data(via: .get)
        XCTAssertEqual(testData, try otherResponse.unwrap())
    }
    
    func testInterceptUrlContainsWorksAsExpected() async throws {
        let googleData = try "google".data(using: .utf8).unwrap()
        let googleInterceptor = Interceptor(when: .urlContains("google.com"), return: .success(googleData))
        HttpClient.add(interceptor: googleInterceptor)
        
        let nexflixData = try "netflix".data(using: .utf8).unwrap()
        let nexflixInterceptor = Interceptor(when: .urlContains("netflix.com"), return: .success(nexflixData))
        HttpClient.add(interceptor: nexflixInterceptor)
        
        let googleClient = HttpClient(baseUrl: "https://www.google.com")
        let googleResponse = await googleClient.data(via: .get)
        XCTAssertEqual(googleData, try googleResponse.unwrap())
        
        let netflixClient = HttpClient(baseUrl: "https://www.netflix.com")
        let netflixResponse = await netflixClient.data(via: .get)
        XCTAssertEqual(nexflixData, try netflixResponse.unwrap())
    }
    
    func testInterceptorCanMakeRequestFail() async throws {
        let interceptor = Interceptor(when: .urlContains("google.com"), return: .failure(.noData))
        HttpClient.add(interceptor: interceptor)
        let client = HttpClient(baseUrl: "https://www.google.com")
        let response = await client.data(via: .get)
        XCTAssertEqual(.failure(.noData), response)
    }
}
