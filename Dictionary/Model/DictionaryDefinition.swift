//
//  Created by Andrew Styles on 20/03/2024.
//

import Foundation


struct DictionaryDefinition: Codable {
    
    struct Meaning: Codable {
       
        struct Definition: Codable {
            let definition: String
            let example: String?
        }
        
        let partOfSpeech: String
        let definitions: [Definition]
    }
    
    let word: String
    let meanings: [Meaning]
}
