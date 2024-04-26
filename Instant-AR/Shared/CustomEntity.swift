import Foundation
import RealityKit

class CustomEntity: Entity, HasAnchoring, HasCollision {
    init(entity: Entity) {
    super.init()
        let anchorPlane = AnchoringComponent.Target.plane(
          .horizontal,
          classification: .any,
          minimumBounds: [0,0])
        let anchorComponent = AnchoringComponent(anchorPlane)
        self.anchoring = anchorComponent
        self.addChild(entity)
        self.collision = CollisionComponent(
          shapes: [ShapeResource.generateBox(size: [1,0.2,1])]
        )
  }

  required init() {
      fatalError(Messages.initError)
  }
}
