//
//  Created by Andrew Styles on 20/03/2024.
//

import Foundation

enum DictionaryServiceError: Error {
    case unsupportedURL
}

protocol DictionaryServiceType {
    func definitions(for word: String) async throws -> [DictionaryDefinition]
}

class DictionaryService: DictionaryServiceType {
    
    private let networkService: NetworkServiceType
    
    init(networkService: NetworkServiceType) {
        self.networkService = networkService
    }

    func definitions(for word: String) async throws -> [DictionaryDefinition] {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)") else {
            throw DictionaryServiceError.unsupportedURL
        }
        return try await networkService.request(request: URLRequest(url: url))
    }
}

