//
//  Created by Andrew Styles on 20/03/2024.
//

import Foundation

struct DictionaryResultViewData: Equatable {

    struct Meaning: Hashable {
        let title: String
        let definitions: [Definition]
    }
    
    struct Definition: Hashable {
        let indexTitle: String
        let title: String
        let example: String?
    }
    
    let word: String
    let meanings: [Meaning]
}

class DictionaryViewModel: ObservableObject {
        
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded(DictionaryResultViewData)
        case error(String)
    }
    
    @Published var state: LoadingState = .idle
    @Published var enteredWord: String = ""
    @Published var submitButtonEnabled = false

    private let service: DictionaryServiceType
    
    init(service: DictionaryServiceType) {
        self.service = service
        
        $state
            .combineLatest($enteredWord)
            .map { $0.0 != .loading && !$0.1.isEmpty }
            .assign(to: &$submitButtonEnabled)
    }
    
    @MainActor
    func submitWord() async {
        guard !enteredWord.isEmpty else { return }
        state = .loading
        do {
            let results = try await service.definitions(for: enteredWord)
            if let firstResult = results.first {
                state = .loaded(
                    .init(
                        word: firstResult.word,
                        meanings: results
                            .flatMap { $0.meanings }
                            .map { .init(title: $0.partOfSpeech, definitions: definitions(from: $0.definitions)) }
                    )
                )
            } else {
                state = .error("No results")
            }
        } catch {
            state = .error("An error occurred, please try again")
        }
    }
    
    private func definitions(
        from definitions: [DictionaryDefinition.Meaning.Definition]
    ) -> [DictionaryResultViewData.Definition] {
        definitions.enumerated().map { (index, element) in
            .init(
                indexTitle: "\(index + 1).",
                title: element.definition,
                example: element.example?.quotation
            )
        }
    }
}

private extension String {
    var quotation: String {
        "\"" + self + "\""
    }
}
