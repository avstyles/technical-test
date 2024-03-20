//
//  Created by Andrew Styles on 20/03/2024.
//

import Foundation

protocol NetworkServiceType {
    func request<T: Decodable>(request: URLRequest) async throws -> T
}

class NetworkService: NetworkServiceType {
    func request<T>(request: URLRequest) async throws -> T where T : Decodable {
        do {
            let data = try await data(for: request)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
    }
    
    private func data(for request: URLRequest) async throws -> Data {
        
        if ProcessInfo().arguments.contains("UI_Testing"),
           let injectedJSON = ProcessInfo().environment[request.url?.absoluteString ?? ""] {
            return injectedJSON.data(using: .utf8)!
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
