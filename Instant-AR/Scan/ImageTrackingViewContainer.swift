import Foundation
import SwiftUI
import RealityKit

struct ImageTrackingViewContainer: UIViewControllerRepresentable {
    
    @EnvironmentObject var networkMonitor: NetworkMonitor

    var discovery: Discovery?
    
    func makeUIViewController(context: Context) -> ImageTrackingARViewController {
        let imageTrackingARViewController = ImageTrackingARViewController(networkMonitor: networkMonitor)
        imageTrackingARViewController.discovery = discovery
        return imageTrackingARViewController
    }
    
    func updateUIViewController(_ uiViewController: ImageTrackingARViewController, context: Context) {
       
    }
    

}
