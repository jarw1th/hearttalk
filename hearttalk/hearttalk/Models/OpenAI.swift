
import Foundation

struct OpenAIResponse: Decodable {
    
    let choices: [Choice]
    
}

struct Choice: Decodable {
    
    let text: String
    
}
