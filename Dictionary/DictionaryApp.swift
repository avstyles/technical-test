//
//  Created by Andrew Styles on 20/03/2024.
//

import SwiftUI

@main
struct DictionaryApp: App {
    
    let networkService = NetworkService()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DictionaryView(
                    viewModel: .init(service: DictionaryService(networkService: networkService))
                )
            }
        }
    }
}
