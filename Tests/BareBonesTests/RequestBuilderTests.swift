import XCTest
@testable import BareBones

final class RequestBuilderTests: XCTestCase {
    func testThrowsErrorIfbaseUrlIsMalformed() {
        let builder = RequestBuilder(baseUrl: "ht tps://www.google.com")
        XCTAssertThrowsError(try builder.buildRequest(via: .get), "") { error in
            XCTAssertEqual(ApiError.malformedUrl, error as? ApiError)
        }
    }
    
    func testThrowsErrorIfUrlCombinedWithPathIsMalformed() {
        let builder = RequestBuilder(baseUrl: testUrl)
        XCTAssertThrowsError(try builder.buildRequest(via: .get, to: "bad stuff"), "") { error in
            XCTAssertEqual(ApiError.malformedUrl, error as? ApiError)
        }
    }
    
    func testQueryParamsAreEncoded() {
        let builder = RequestBuilder(baseUrl: testUrl)
        let params: [String: Any] = [
            "multipleWords": "These are multiple words",
            "numberTwelve": 12,
            "singleWord": "Word"
        ]
        let result = builder.queryItems(for: params)
        let expected = "multipleWords=These%20are%20multiple%20words&numberTwelve=12&singleWord=Word"
        XCTAssertEqual(expected, result)
    }
    
    func testQueryIsEmptyIfParamsAreEmpty() {
        let builder = RequestBuilder(baseUrl: testUrl)
        let result = builder.query(for: .url(params: [:]))
        XCTAssertEqual("", result)
    }
    
    func testNonEmptyQueryStartsWithQuestionMark() {
        let builder = RequestBuilder(baseUrl: testUrl)
        let result = builder.query(for: .url(params: ["a": "b"]))
        XCTAssertEqual("?a=b", result)
    }
    
    func testRequestBodyIsSetFromEncodable() {
        let content = TestParams()
        let builder = RequestBuilder(baseUrl: testUrl)
        let result = try? builder.requestBody(from: .body(body: content))
        let expected = try? JSONEncoder().encode(content)
        XCTAssertNotNil(expected)
        XCTAssertNotNil(result)
        XCTAssertEqual(expected, result)
    }
    
    func testHttpHeadersAreSet() throws {
        let builder = RequestBuilder(baseUrl: testUrl)
        let request = try builder.buildRequest(via: .get, httpHeaders: ["hello": "world"])
        XCTAssertEqual("world", request.allHTTPHeaderFields?["hello"])
    }
}

private struct TestParams: Codable {
    var banana: String = "banana"
    var coconut: Int = 13
    var stuff: [String] = ["not empty"]
    var nothing: [String] = []
}

private let testUrl = "https://www.google.com"
