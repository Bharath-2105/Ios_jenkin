import SwiftUI
import Combine

class OrientationObserver: ObservableObject {
    @Published var isLandscape: Bool = false
    @Published var orientationAngle: Double = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to orientation changes
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ -> (Bool, Int) in
                switch UIDevice.current.orientation {
                case .landscapeLeft:
                    return (true, 90) // Landscape left as 90 degrees
                case .landscapeRight:
                    return (true, -90) // Landscape right as -90 degrees
                default:
                    return (false, 0) // All other cases as 0 degrees
                }
            }
            .sink { [weak self] isLandscape, angle in
                self?.isLandscape = isLandscape
                self?.orientationAngle = Double(angle)
            }
            .store(in: &cancellables)
        
        // Set initial orientation
        let initialOrientation = UIDevice.current.orientation
        switch initialOrientation {
        case .landscapeLeft:
            self.isLandscape = true
            self.orientationAngle = 90
        case .landscapeRight:
            self.isLandscape = true
            self.orientationAngle = -90
        default:
            self.isLandscape = false
            self.orientationAngle = 0
        }
    }
}
