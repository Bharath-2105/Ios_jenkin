import SwiftUI
import RealityFoundation
import RealityKit


struct ModelView: UIViewRepresentable {
        
    var localFilePath: String?
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        
        let arView = ARView(frame: containerView.bounds)
        arView.cameraMode = .nonAR
        context.coordinator.arView = arView

        do{
            // Configure your ARView and load models as needed
            if let filePath = localFilePath, let fileUrl = URL(string: filePath){
                let modelEntity = try ModelEntity.load(contentsOf: fileUrl)
                
                let pivotEntity = Entity()
                pivotEntity.addChild(modelEntity)
                context.coordinator.targetEntity = pivotEntity

                // Calculate the visual bounds of the modelEntity relative to the pivotEntity.
                let bounds = modelEntity.visualBounds(relativeTo: pivotEntity)

                // The center of the bounding box relative to the pivotEntity.
                let boundingBoxCenter = bounds.center

                // Calculate the adjustment needed to center the bounding box in the pivotEntity's coordinate space.
                // This considers the bounding box's current center (relative to the pivot) to determine how much to move the modelEntity.
                let adjustment = -boundingBoxCenter

                // Adjust the modelEntity's position. This operation centers the bounding box in the pivotEntity's coordinate space.
                modelEntity.position += adjustment

                // Add the pivotEntity (with the modelEntity) to the scene, centered as required.
                let anchorEntity = AnchorEntity()
                anchorEntity.addChild(pivotEntity)
                arView.scene.addAnchor(anchorEntity)
                
                for animation in modelEntity.availableAnimations {
                    modelEntity.playAnimation(animation.repeat())
                }
            }
        } catch{
            let toast = FancyToast(type: .error, title: FancyToastStyle.error.rawValue, message: Messages.modelLoadingFailed, duration: -1)
            arView.showToast(toast: toast)
        }
        
        containerView.addSubview(arView)
        
        createBackground(for: arView)
        
        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: containerView.topAnchor),
            arView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Initialize gesture recognizers in the coordinator
        context.coordinator.setupGestures()
        
        return containerView
    }
    
    func createBackground(for arView: ARView) {

        var material = SimpleMaterial()
        
        material.color = .init(tint: .lightGray, texture: nil)
        material.metallic = 0.5
        
        // Create a large plane to act as the background
        let plane = ModelEntity(mesh: .generatePlane(width: 100.0, height: 100.0), materials: [material])
        plane.position = [0, 0, -1] // Position the plane in front of the camera
        
        // Create an anchor and add the plane to it
        let anchor = AnchorEntity()
        anchor.addChild(plane)
        
        // Add the anchor to the ARView's scene
        arView.scene.addAnchor(anchor)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Perform updates to the ARView if needed
    }
    
    class Coordinator: NSObject {
        
        var arView: ARView?
        var targetEntity: Entity?
        private var originalScale: SIMD3<Float> = SIMD3<Float>(1, 1, 1)
        private var originalRotation: simd_quatf = simd_quatf(angle: 0, axis: [0, 1, 0])
        private var originalPosition: SIMD3<Float> = SIMD3<Float>(1, 1, 1)
        
        func setupGestures() {
            
            guard let arView = self.arView else { return }
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            arView.addGestureRecognizer(pinchGesture)
            
            let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
            arView.addGestureRecognizer(rotationGesture)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSingleFingerRotation(_:)))
            arView.addGestureRecognizer(panGesture)
            
            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapGesture.numberOfTapsRequired = 2
            arView.addGestureRecognizer(doubleTapGesture)
            
            
            guard let entity = targetEntity else { return }
            
            originalScale    = entity.scale
            originalPosition = entity.position
            originalRotation = entity.transform.rotation
            
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let entity = targetEntity else { return }
            
            if gesture.state == .began || gesture.state == .changed {
                let scale = gesture.scale
                entity.scale *= SIMD3<Float>(repeating: Float(scale))
                gesture.scale = 1 // Reset scale to avoid compounding the scale factor
                
            }
        }
        
        @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
            guard let entity = targetEntity else { return }
            
            if gesture.state == .began || gesture.state == .changed {
                let rotation = gesture.rotation
                entity.transform.rotation *= simd_quatf(angle: Float(rotation), axis: [0, 1, 0]) // Rotate around the y-axis
                gesture.rotation = 0 // Reset rotation to avoid compounding the rotation
            }
        }
        
        @objc func handleSingleFingerRotation(_ gesture: UIPanGestureRecognizer) {
            guard let arView = self.arView, let entity = targetEntity else { return }
            
            let translation = gesture.translation(in: arView)
            gesture.setTranslation(CGPoint.zero, in: arView) // Reset translation
            
            if gesture.state == .changed {
                // Assuming horizontal drag rotates around Y-axis
                // Convert translation delta to radians for rotation.
                // You might need to adjust the sensitivity (the `0.02` factor here).
                let rotationAngle = Float(translation.x) * 0.02
                
                
                // Rotate around X-axis
                let rotationAxis = SIMD3<Float>(0, 1, 0)
                let deltaRotation = simd_quatf(angle: rotationAngle, axis: rotationAxis)
                
                let rotationAngleY = Float(translation.y) * 0.01
                let rotationAxisY = SIMD3<Float>(1, 0, 0)
                let deltaRotationY = simd_quatf(angle: rotationAngleY, axis: rotationAxisY)
                
                // Apply rotation to the entity's current rotation
                entity.transform.rotation = deltaRotation * deltaRotationY * entity.transform.rotation
            }
        }
        
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let entity = targetEntity else { return }
            
            let animationDuration: TimeInterval = 0.3 // Customize the duration
            
            // Animate back to original position, scale, and rotation
            let originalTransform = Transform(scale: originalScale, rotation: originalRotation, translation: originalPosition)
            
            entity.move(to: originalTransform, relativeTo: entity.parent, duration: animationDuration, timingFunction: .easeInOut)
        }
        
    }
}
