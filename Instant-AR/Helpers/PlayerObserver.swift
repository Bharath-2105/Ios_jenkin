import Foundation
import Combine
import AVFoundation

class PlayerObserver: ObservableObject {
    var player: AVPlayer {
        didSet {
            observeCurrentItem(player.currentItem)
        }
    }
    private var cancellables = Set<AnyCancellable>()
    @Published var isBuffering: Bool = true
    
    init(player: AVPlayer) {
        self.player = player
        observeCurrentItem(player.currentItem)
    }
    
    private func observeCurrentItem(_ item: AVPlayerItem?) {
        cancellables.removeAll()
        
        // Observe the isPlaybackLikelyToKeepUp property
        item?.publisher(for: \.isPlaybackLikelyToKeepUp)
            .receive(on: DispatchQueue.main)
            .map { !$0 }
            .sink { [weak self] needsBuffering in
                self?.isBuffering = needsBuffering
            }
            .store(in: &cancellables)
        
        // Observe the status property
        item?.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                    case .readyToPlay:
                        self?.isBuffering = false
                    case .failed, .unknown:
                        self?.isBuffering = true
                    @unknown default:
                        break
                }
            }
            .store(in: &cancellables)
    }
}
