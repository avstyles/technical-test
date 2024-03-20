//
//  Created by Andrew Styles on 20/03/2024.
//

import SwiftUI

struct DictionaryView: View {
    
    @ObservedObject var viewModel: DictionaryViewModel
    
    @FocusState private var textFieldIsFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            searchBarView()
            Spacer()
        
            switch viewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .loaded(let viewData):
                ResultsView(viewData: viewData)
            case .error(let message):
                Text(message)
            }
            Spacer()
        }
        .navigationTitle("Dictionary")
    }
    
    func searchBarView() -> some View {
        HStack(spacing: 8) {
            TextField("Enter any word", text: $viewModel.enteredWord)
                .focused($textFieldIsFocused)
                .onSubmit {
                    Task {
                        await viewModel.submitWord()
                    }
                }
                .padding(8)
                .border(.black, width: 1)
            Button("Submit") {
                textFieldIsFocused = false
                Task {
                    await viewModel.submitWord()
                }
            }
            .disabled(viewModel.enteredWord.isEmpty)
        }
        .padding(16)
    }
    
    struct ResultsView: View {
        
        let viewData: DictionaryResultViewData
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewData.word)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    ForEach(viewData.meanings, id: \.self) { meaning in
                        MeaningsView(meaning: meaning)
                        Divider()
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    struct MeaningsView: View {
        
        let meaning: DictionaryResultViewData.Meaning
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text(meaning.title)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                ForEach(meaning.definitions, id: \.self) { definition in
                    DefinitionView(definition: definition)
                }
            }
        }
    }
    
    struct DefinitionView: View {
        
        let definition: DictionaryResultViewData.Definition
        
        var body: some View {
            HStack(alignment: .top, spacing: 8) {
                Text(definition.indexTitle)
                VStack(alignment: .leading, spacing: 8) {
                    Text(definition.title)
                        .font(.body)
                    if let example = definition.example {
                        Text(example)
                            .font(.body)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    DictionaryView(viewModel: .init(service: DictionaryService(networkService: NetworkService())))
}
