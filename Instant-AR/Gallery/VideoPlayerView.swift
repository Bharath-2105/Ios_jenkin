import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject private var orientationObserver = OrientationObserver()
    @StateObject private var playerObserver: PlayerObserver
    @State var player: AVPlayer
    
    init(videoURL: String) {
        if let url = URL(string: videoURL){
            let player = AVPlayer(url: url)
            self._player = State(initialValue: player)
            self._playerObserver = StateObject(wrappedValue: PlayerObserver(player: player))
           
        } else {
            let player = AVPlayer()
            self._player = State(initialValue: player)
            self._playerObserver = StateObject(wrappedValue: PlayerObserver(player: player))
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
    
                VideoPlayer(player: player)
                    .frame(width: orientationObserver.isLandscape ? geometry.size.height : geometry.size.width, height: orientationObserver.isLandscape ? geometry.size.width :geometry.size.height)
                    .edgesIgnoringSafeArea(.all)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                if playerObserver.isBuffering == true {
                    ProgressView()
                        .scaleEffect(1.5, anchor: .center)
                }
            }
            .rotationEffect(.degrees(orientationObserver.orientationAngle))
            .onAppear {
                player.play()
            }
            .onDisappear {
                player.pause()
            }
            .onChange(of: networkMonitor.isConnected ?? false) { newValue in
                if newValue {
                    player.play()
                } else {
                    player.pause()
                }
            }
            .statusBar(hidden: orientationObserver.isLandscape)
        }
        .ignoresSafeArea(edges: [.horizontal, .bottom])
        .navigationBarBackButtonHidden(true)
    }
}
