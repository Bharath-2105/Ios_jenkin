import UIKit
import RealityKit
import ARKit

class ElasticARImage {
    private weak var arView: ARView?
    private var imageAnchor: AnchorEntity?
    private var base64ImageData: String
    
    init(arView: ARView, base64ImageData: String) {
        self.arView = arView
        self.base64ImageData = base64ImageData
        setupImage()
    }
    
    
    private func setupImage() {
        guard let arView = arView else { return }
        
        if let base64DataIndex = base64ImageData.range(of: Constants.base64)?.upperBound {
            let base64StringWithoutPrefix = String(base64ImageData[base64DataIndex...])

            if let imageData = Data(base64Encoded: base64StringWithoutPrefix) {
                if let image = UIImage(data: imageData) {
                    let anchor = AnchorEntity(world: [0, 0, -0.5])
                    self.imageAnchor = anchor
                    arView.scene.addAnchor(anchor)
                    
                    // Image setup
                    let aspectRatio = image.size.width / image.size.height
                    let isPortrait = image.size.height > image.size.width
                    let fixedDimension: Float = 0.1 // Fixed dimension (either width or height)
                    let planeWidth = isPortrait ? fixedDimension : fixedDimension * Float(aspectRatio)
                    let planeHeight = isPortrait ? fixedDimension / Float(aspectRatio) : fixedDimension
                    
                    var imageMaterial = UnlitMaterial()
                    
                    let options = TextureResource.CreateOptions(semantic: .none)
                    if let texture = try? TextureResource.generate(from: image.cgImage!, options: options) {
                        imageMaterial.baseColor = MaterialColorParameter.texture(texture)
                        imageMaterial.tintColor = UIColor(white: 1.0, alpha: 0.9)
                        let planeMesh = MeshResource.generatePlane(width: planeWidth, height: planeHeight)
                        let imageEntity = ModelEntity(mesh: planeMesh, materials: [imageMaterial])
                        imageEntity.position = [0, 0, 0] // Centered on anchor
                        anchor.addChild(imageEntity)
                        
                    }
                }
            }
        }
    }


    
    func updatePosition() {
        guard let arView = arView, let cameraTransform = arView.session.currentFrame?.camera.transform else { return }
        
        let cameraPosition = simd_make_float3(cameraTransform.columns.3)
        // Adjust the target position to be in front of the camera
        let targetPosition = cameraPosition + simd_make_float3(-cameraTransform.columns.2.x, -cameraTransform.columns.2.y, -cameraTransform.columns.2.z) * 0.5 // 0.5 meters in front of the camera
        
        DispatchQueue.main.async {
            // Update the position of the imageAnchor
        
            self.imageAnchor?.setPosition(SIMD3<Float>(targetPosition.x, targetPosition.y, targetPosition.z), relativeTo: nil)
            
            // Aim to face the camera while maintaining an "upright" orientation regarding the world's up vector.
            // This calculation aims to orient the imageAnchor directly at the camera without inheriting the camera's pitch and roll.
            let directionToCamera = simd_normalize(cameraPosition - targetPosition)
            let upVector = SIMD3<Float>(0, 1, 0) // World's up vector
            let rightVector = simd_cross(upVector, directionToCamera)
            let correctedUpVector = simd_cross(directionToCamera, rightVector)
            let orientationMatrix = matrix_float4x4(
                columns: (
                    SIMD4<Float>(rightVector.x, rightVector.y, rightVector.z, 0),
                    SIMD4<Float>(correctedUpVector.x, correctedUpVector.y, correctedUpVector.z, 0),
                    SIMD4<Float>(directionToCamera.x, directionToCamera.y, directionToCamera.z, 0),
                    SIMD4<Float>(0, 0, 0, 1)
                )
            )

            let orientationQuaternion = simd_quaternion(orientationMatrix)
            
            self.imageAnchor?.setOrientation(orientationQuaternion, relativeTo: nil)
        }
    }
    
    public func hide(){
        imageAnchor?.removeFromParent()
    }
}
