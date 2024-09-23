
import AVFoundation

final class SoundManager {
    
    static let shared = SoundManager()
    var audioPlayer: AVAudioPlayer?

    private func playSound(named soundName: String) {
        if UserDefaults.standard.bool(forKey: "isSounds") == nil || UserDefaults.standard.bool(forKey: "isSounds") == true {
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error)")
            }
            
        }
    }
    
    func sound(_ type: SoundType) {
        switch type {
        case .card:
            playSound(named: "CardSwipe")
        case .click1:
            playSound(named: "Click1")
        }
    }
    
}

enum SoundType {
    
    case card, click1
    
}
