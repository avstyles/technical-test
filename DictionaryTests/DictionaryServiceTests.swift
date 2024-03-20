//
//  Created by Andrew Styles on 20/03/2024.
//

import XCTest
import Combine
@testable import Dictionary

final class DictionaryServiceTests: XCTestCase {
    
    var sut: DictionaryService!
    var networkServiceMock: NetworkServiceMock!
    
    override func setUp() {
        networkServiceMock = .init()
        sut = .init(networkService: networkServiceMock)
    }
    
    func test_definitionsForWord_createsExpectedURL() async throws {
        //given
        _ = try await sut.definitions(for: "test")
        // then
        XCTAssertEqual(
            networkServiceMock.capturedRequest?.url?.absoluteString,
            "https://api.dictionaryapi.dev/api/v2/entries/en/test"
        )
    }
}

class NetworkServiceMock: NetworkServiceType {
    var capturedRequest: URLRequest?
    func request<T>(request: URLRequest) async throws -> T where T : Decodable {
        capturedRequest = request
        return try JSONDecoder().decode(T.self, from: "[]".data(using: .utf8)!)
    }
}
