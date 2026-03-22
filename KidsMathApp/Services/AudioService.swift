import AVFoundation
import SwiftUI

class AudioService: ObservableObject {
    static let shared = AudioService()

    @Published var isSoundEnabled: Bool = true
    @Published var isMusicEnabled: Bool = false

    private var audioPlayer: AVAudioPlayer?

    func playCorrectSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1025) // subtle positive tone
    }

    func playWrongSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1053) // gentle tone
    }

    func playCelebrationSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1335) // celebration
    }

    func playTapSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1104) // tap
    }

    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}
