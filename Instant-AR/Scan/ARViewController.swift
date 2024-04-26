import SwiftUI
import RealityKit
import ARKit
import Kingfisher

class ARViewController: UIViewController, ARSessionDelegate {
    
    var arView: ARView!
    var videoUrl: String? = nil
    var markerImageUrl:String? = nil
    var isModelPlaced: Bool = false
    var discoveryType : DiscoveryType = .unknown
    let coachingOverlay = ARCoachingOverlayView()
    var entity: CustomEntity?
    var toast: FancyToast?
    
    var localModelPath: String? = nil {
        didSet {
            loadThreeDModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arView = ARView(frame: .zero)
        view.addSubview(arView)
        arView.session.delegate = self
        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        entity = nil
        arView?.scene.anchors.removeAll()
        arView?.session.pause()
        arView?.removeFromSuperview()
    }
    
    func setupARView() {
        if(discoveryType == .model){
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = [.horizontal]
            configuration.environmentTexturing = .automatic
            arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            addCoaching()
        }
    }
}

extension ARViewController : ARCoachingOverlayViewDelegate {
    
    func addCoaching() {
        self.coachingOverlay.delegate = self
        self.coachingOverlay.session = self.arView.session
        self.coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.coachingOverlay.goal = .horizontalPlane
        self.arView.addSubview(self.coachingOverlay)
        self.coachingOverlay.setActive(true, animated: true)
    }
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        if let entity = entity {
            if !isModelPlaced {
                coachingOverlayView.activatesAutomatically = false
                let modelAnchor = AnchorEntity()
                modelAnchor.addChild(entity)
                arView.scene.addAnchor(modelAnchor)
                toast = nil
                for animation in entity.availableAnimations {
                    entity.playAnimation(animation.repeat())
                }
                arView.installGestures([.rotation, .translation], for: entity)
                self.isModelPlaced = true
            }
        } else {
            if let toast = toast {
                arView.showToast(toast: toast)
            }
        }
    }
    func loadThreeDModel() {
        if let modelPath = localModelPath, let threeDModelURL = URL(string: modelPath) {
            do {
                toast = FancyToast(type: .info, title: FancyToastStyle.info.rawValue, message: Messages.modelLoadingInProgress, duration: -1)
                let modelEntity = try ModelEntity.load(contentsOf: threeDModelURL)
                entity = CustomEntity(entity: modelEntity)
            } catch {
                toast = FancyToast(type: .error, title: FancyToastStyle.error.rawValue, message: Messages.modelLoadingFailed, duration: -1)
            }
        }
    }
}
