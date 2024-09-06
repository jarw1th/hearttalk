
import Alamofire

final class NetworkManager {
    
    private let apiKey = "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"
    private let apiURL = "https://api.openai.com/v1/completions"
    
    func createQuestion(prompt: String) async throws -> String {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": prompt,
            "max_tokens": 50
        ]
        
        let request = AF.request(apiURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                
        let response = try await request.serializingDecodable(OpenAIResponse.self).response
        
        if let choice = response.value?.choices.first {
            return choice.text
        } else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
    }
    
}
