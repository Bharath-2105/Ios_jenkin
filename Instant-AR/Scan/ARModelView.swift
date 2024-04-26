import SwiftUI
import RealityKit

struct ARModelView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var localFilePath: String?
    var discoveryType: DiscoveryType = .unknown
    
    func makeUIViewController(context: Context) -> ARViewController {
        let arViewController = ARViewController()
        arViewController.localModelPath = localFilePath
        arViewController.discoveryType = discoveryType
        return arViewController
    }
    
    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        uiViewController.setupARView()
    }
    
}
