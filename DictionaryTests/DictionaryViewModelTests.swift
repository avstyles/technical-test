//
//  Created by Andrew Styles on 20/03/2024.
//

import XCTest
import Combine
@testable import Dictionary

final class DictionaryViewModelTests: XCTestCase {
    
    var sut: DictionaryViewModel!
    var dictionaryServiceMock: DictionaryServiceMock!
    var cancellables: [AnyCancellable] = []
    
    override func setUp() {
        dictionaryServiceMock = .init()
        sut = .init(service: dictionaryServiceMock)
    }
    
    func testInit_stateIsIdle() {
        XCTAssertEqual(sut.state, .idle)
    }
    
    func testInit_enteredWordIsEmpty() {
        XCTAssertTrue(sut.enteredWord.isEmpty)
    }
    
    func testSubmitButtonEnabled_emptyWord_idleState_isFalse() {
        // given
        sut.enteredWord = ""
        sut.state = .idle
        // then
        XCTAssertFalse(sut.submitButtonEnabled)
    }
    
    func testSubmitButtonEnabled_word_idleState_isTrue() {
        // given
        sut.enteredWord = "test"
        sut.state = .idle
        // then
        XCTAssertTrue(sut.submitButtonEnabled)
    }
    
    func testSubmitButtonEnabled_word_loadingState_isFalse() {
        // given
        sut.enteredWord = "test"
        sut.state = .loading
        // then
        XCTAssertFalse(sut.submitButtonEnabled)
    }
    
    func testSubmitButtonEnabled_word_loadedState_isTrue() {
        // given
        sut.enteredWord = "test"
        sut.state = .loaded(.init(word: "test", meanings: []))
        // then
        XCTAssertTrue(sut.submitButtonEnabled)
    }
    
    func testSubmitWord_enteredWord_stateIsLoading() async {
        // given
        sut.enteredWord = "test"
        var nextStateIsLoading = false
        sut.$state
            .sink { [weak self] in
                nextStateIsLoading = $0 == .loading
                self?.cancellables.removeAll()
            }
            .store(in: &cancellables)
        // when
        await sut.submitWord()
        // then
        XCTAssertTrue(nextStateIsLoading)
    }
    
    func testSubmitWord_enteredWord_callsDictionaryServiceWithWord() async {
        // given
        sut.enteredWord = "test"
        // when
        await sut.submitWord()
        // then
        XCTAssertEqual(dictionaryServiceMock.capturedWord, "test")
    }
    
    func testSubmitWord_dictionaryServiceThrowsError_stateIsError() async {
        // given
        sut.enteredWord = "test"
        dictionaryServiceMock.errorToThrow = MockError.error
        // when
        await sut.submitWord()
        // then
        XCTAssertEqual(sut.state, .error("An error occurred, please try again"))
    }
    
    func testSubmitWord_dictionaryServiceReturnsEmptyResults_stateIsErrorNoResults() async {
        // given
        sut.enteredWord = "test"
        dictionaryServiceMock.definitionToReturn = []
        // when
        await sut.submitWord()
        // then
        XCTAssertEqual(sut.state, .error("No results"))
    }
    
    func testSubmitWord_dictionaryServiceReturnsWithResult_stateIsLoaded() async {
        // given
        sut.enteredWord = "test"
        dictionaryServiceMock.definitionToReturn = [
            .init(
                word: "test",
                meanings: [
                    .init(
                        partOfSpeech: "noun",
                        definitions: [.init(definition: "definition", example: "example")]
                    )
                ]
            )
        ]
        // when
        await sut.submitWord()
        // then
        XCTAssertEqual(
            sut.state,
            .loaded(
                .init(
                    word: "test",
                    meanings: [
                        .init(
                            title: "noun",
                            definitions: [.init(indexTitle: "1.", title: "definition", example: "\"example\"")]
                        )
                    ]
                )
            )
        )
    }
    
    func testSubmitWord_dictionaryServiceReturnsWithMultipleResults_stateIsLoaded() async {
        // given
        sut.enteredWord = "test"
        dictionaryServiceMock.definitionToReturn = [
            .init(
                word: "test",
                meanings: [
                    .init(
                        partOfSpeech: "noun",
                        definitions: [.init(definition: "definition 1", example: "example")]
                    )
                ]
            ),
            .init(
                word: "test",
                meanings: [
                    .init(
                        partOfSpeech: "verb",
                        definitions: [
                            .init(definition: "definition 2", example: nil),
                            .init(definition: "definition 3", example: nil)
                        ]
                    )
                ]
            ),
        ]
        // when
        await sut.submitWord()
        // then
        XCTAssertEqual(
            sut.state,
            .loaded(
                .init(
                    word: "test",
                    meanings: [
                        .init(
                            title: "noun",
                            definitions: [.init(indexTitle: "1.", title: "definition 1", example: "\"example\"")]
                        ),
                        .init(
                            title: "verb",
                            definitions: [
                                .init(indexTitle: "1.", title: "definition 2", example: nil),
                                .init(indexTitle: "2.", title: "definition 3", example: nil)
                            ]
                        )
                    ]
                )
            )
        )
    }
}

enum MockError: Error {
    case error
}

class DictionaryServiceMock: DictionaryServiceType {
    
    var capturedWord: String?
    var errorToThrow: Error?
    var definitionToReturn: [DictionaryDefinition]?
    
    func definitions(for word: String) async throws -> [DictionaryDefinition] {
        capturedWord = word
        
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return definitionToReturn ?? []
    }
}
