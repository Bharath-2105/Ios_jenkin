import Foundation
import SwiftUI
import RealityKit
import ARKit

class ImageTrackingARViewController: UIViewController, ARSessionDelegate{
    var arView: ARView!
    var discovery: Discovery?
    var player = AVPlayer()
    var muteUnMuteButton: UIButton?
    var lookingForText = UILabel()
    var markerImageLocalPath: URL?
    var elasticImage: ElasticARImage?
    var imageAnchor:ARImageAnchor? = nil
    var anchorEntity:AnchorEntity? = nil
    var videoSize:CGSize? = nil
    var videoMeterial : VideoMaterial? = nil
    var isVideoReadyToPlay : Bool = false
    var networkMonitor: NetworkMonitor?
    var observedKeyPath: String = ""
    var entity: Entity?
    var toast: FancyToast?

    var placementObjectLocalPath: URL? {
        didSet {
            loadThreeDModel()
        }
    }
    
    init(networkMonitor: NetworkMonitor? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.networkMonitor = networkMonitor
    }
    
    required init?(coder: NSCoder) {
        fatalError(Messages.initCoderError)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadCachedImage(notification:)), name: .downloadComplete, object: nil)
       
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
        
        elasticImage = ElasticARImage(arView: arView, base64ImageData: discovery!.markerImagebase64)
        setUpLookingForText()
        
        if let markerImageUrl = discovery?.imageUrl{
            markerImageLocalPath = FileCache.shared.getCachedFile(for: markerImageUrl)
        }
        
        if let placementImageUrl = discovery?.mediaInfo, discovery?.type == .image {
            placementObjectLocalPath = FileCache.shared.getCachedFile(for: placementImageUrl)
        } else if let placementImageUrl = discovery?.threeDModelUsdz, discovery?.type == .model {
            placementObjectLocalPath = FileCache.shared.getCachedFile(for: placementImageUrl)
        }
        configureARImageTracking(with: discovery)
        networkMonitor?.networkMonitorCallBack = { isConnected in
            if let isConnected = isConnected, self.isVideoReadyToPlay, self.discovery?.type == .video {
                isConnected ? self.player.play() : self.player.pause()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if discovery?.type == .video && isVideoReadyToPlay {
            player.pause()
        }
        isVideoReadyToPlay = false
        self.entity?.removeFromParent()
        self.entity = nil
        self.arView.session.pause()
        self.removePlayerObserver()
        self.networkMonitor?.networkMonitorCallBack = nil
        self.arView.removeFromSuperview()
        self.arView = nil
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleDownloadCachedImage(notification: Notification){
        
        if let userInfo = notification.userInfo, let url = userInfo[Constants.url] as? String, let localFilePath = userInfo[Constants.localFilePath] as? String{
            
            if(url == discovery?.imageUrl){ // Marker Image
                markerImageLocalPath = URL(string: localFilePath )
                configureARImageTracking(with: discovery)
            }
            
            if url == discovery?.mediaInfo || url == discovery?.threeDModelUsdz {
                placementObjectLocalPath = URL(string: localFilePath )
                if let imageAnchor = self.imageAnchor {
                    self.placeObjectOnImageAnchor(anchor: imageAnchor)
                }
            }
        }
    }
  
    
    func configureARImageTracking(with discovery: Discovery?) {
        
        let physicalWidth: CGFloat = 0.2
        var imageData: Data?

        if let markerImageUrl = markerImageLocalPath {
            imageData = try? Data(contentsOf: markerImageUrl)
        } else if let base64String = discovery?.markerImagebase64.split(separator: ",").last {
            imageData = Data(base64Encoded: String(base64String))
        }

        guard let data = imageData, let image = UIImage(data: data), let cgImage = image.cgImage else { return }

        self.arView.session.pause()
        let configuration = ARImageTrackingConfiguration()
        let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: physicalWidth)
        configuration.trackingImages = [referenceImage]
        configuration.maximumNumberOfTrackedImages = 1
        self.arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
               
                elasticImage?.hide()
                lookingForText.isHidden = true
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.notificationOccurred(.success)
                if self.discovery?.type == .video{
                    self.addMuteUnMuteButton()
                }
                
                self.placeObjectOnImageAnchor(anchor: imageAnchor)
            }
        }
    }
    
    func updateAnchor(_ imageAnchor: ARImageAnchor, with videoEntity: ModelEntity) {
        // Update the position or orientation of the videoEntity based on the imageAnchor
        // For example, you might want to adjust the position or scale
        videoEntity.position = [0, 0, 0] // Adjust as needed
        // You can also update other properties like scale or orientation
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        elasticImage?.updatePosition()
    }
    
    func placeObjectOnImageAnchor(anchor imageAnchor : ARImageAnchor){
        
        if let anchorEntity = self.anchorEntity{
            anchorEntity.removeFromParent()
            self.anchorEntity = nil
        }
        
        self.imageAnchor = imageAnchor
        
        var planeEntity : ModelEntity? = nil
        if(discovery?.type == .image && placementObjectLocalPath != nil){
            planeEntity = createImagePlaneEnitity(for: imageAnchor.referenceImage.physicalSize)
        } else if(discovery?.type == .video) {
            if( isVideoReadyToPlay ){
                planeEntity = createVideoPlaneEntity(for: imageAnchor.referenceImage.physicalSize)
            } else {
                planeEntity = createPlaceholderPlaneEntity(for: imageAnchor.referenceImage.physicalSize)
                setupVideoPlayer()
            }
        } else if discovery?.type == .model && placementObjectLocalPath != nil {
            planeEntity = createThreeDModelPlaneEntity()
        } else {
            planeEntity = createPlaceholderPlaneEntity(for: imageAnchor.referenceImage.physicalSize)
        }
        
        self.anchorEntity = AnchorEntity(anchor: imageAnchor)
        if (self.anchorEntity != nil && planeEntity != nil) {
            if discovery?.type != .model {
                  planeEntity!.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
            }
            self.anchorEntity!.addChild(planeEntity!)
            self.arView.scene.addAnchor(self.anchorEntity!)
        }
    }
    
    func createImagePlaneEnitity(for markerSize: CGSize) -> ModelEntity? {
        
        var modelEntity : ModelEntity? = nil
        if let url = placementObjectLocalPath {
            var photoMaterial = UnlitMaterial()
            do {
                let texture = try TextureResource.load(contentsOf: url)
                photoMaterial.baseColor = MaterialColorParameter.texture(texture)
                let planeSize = calculatePlaneSize(for: markerSize, and: CGSize(width: texture.width, height: texture.height))
                let mesh = MeshResource.generatePlane(width: Float(planeSize.width), height: Float(planeSize.height))
                modelEntity = ModelEntity(mesh: mesh, materials: [photoMaterial])
                
            }
            catch {
                print(Constants.error)
            }
        }
        return modelEntity
    }
    
    
    func scanningLineMaterial() -> CustomMaterial {
        // Ensure the Metal device is available
        guard let device = MTLCreateSystemDefaultDevice(),
              let defaultLibrary = device.makeDefaultLibrary() else {
            fatalError(Messages.metalFailureError)
        }

        let shader = CustomMaterial.SurfaceShader(
                                                  named: Constants.basicShader,
                                                     in: defaultLibrary)
       let modifier = CustomMaterial.GeometryModifier(
                                          named: Constants.basicModifier,
                                             in: defaultLibrary)

        do {
            
            // Create a custom material using the surface shader
            let customMaterial = try CustomMaterial(
                                        surfaceShader: shader,
                                     geometryModifier: modifier,
                                        lightingModel: .lit)

            return customMaterial
        } catch {
            fatalError(Messages.customMaterialCreationError + "\(error)")
        }
    }
    
    func createPlaceholderPlaneEntity(for markerSize: CGSize) -> ModelEntity? {

        let mesh = MeshResource.generatePlane(width: Float(markerSize.width), height: Float(markerSize.height))
        let customMaterial = scanningLineMaterial()
        let modelEntity = ModelEntity(mesh: mesh, materials: [customMaterial])
        return modelEntity
    }
    
    func setupVideoPlayer(){
        
        guard let url = URL(string: discovery?.mediaInfo ?? "") else {
            return
        }
        
        player = AVPlayer(url: url)
        self.videoMeterial = VideoMaterial(avPlayer: player)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            self.player.seek(to: CMTime.zero)
            self.player.play()
        }
        
        self.addPlayerObserver()
    }
    
    func addPlayerObserver() {
        player.addObserver(self, forKeyPath: Constants.keypath, options: [.initial, .new], context: nil)
        observedKeyPath = Constants.keypath
    }
    
    func removePlayerObserver() {
        if observedKeyPath == Constants.keypath {
            player.removeObserver(self, forKeyPath: observedKeyPath, context: nil)
            observedKeyPath.removeAll()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == Constants.keypath {

            guard let tracks = player.currentItem?.tracks else {
                return
            }
            
            let sizes: [CGSize] = tracks.compactMap { track -> CGSize? in
                track.assetTrack?.naturalSize
            }
            guard let size: CGSize = sizes.filter({ size -> Bool in
                size.width > 0 && size.height > 0
            }).first else {
                return
            }
            
            videoSize = size
            self.isVideoReadyToPlay = true
            if(self.imageAnchor != nil){
                self.placeObjectOnImageAnchor(anchor: self.imageAnchor!)
            }
            player.play()
        }
    }
    
    func createVideoPlaneEntity(for markerSize: CGSize) -> ModelEntity? {
        
        var modelEntity : ModelEntity? = nil
        if let videoSize = self.videoSize, let videoMeterial = self.videoMeterial{
            let planeSize = calculatePlaneSize(for: markerSize, and: videoSize)
            let mesh = MeshResource.generatePlane(width: Float(planeSize.width), height: Float(planeSize.height))
            modelEntity = ModelEntity(mesh: mesh, materials: [videoMeterial])
        }
        return modelEntity
    }
    
    func createThreeDModelPlaneEntity() -> ModelEntity? {
        var modelEntity: ModelEntity?
        if let _ = placementObjectLocalPath, let entity = entity {
            modelEntity = ModelEntity()
            modelEntity?.addChild(entity)
            for animation in entity.availableAnimations {
                entity.playAnimation(animation.repeat())
            }
            toast = nil
        } else {
            if let toast = toast {
                arView.showToast(toast: toast)
            }
        }
        return modelEntity
    }
    
    func loadThreeDModel() {
        if let placementObjectLocalPath = placementObjectLocalPath, entity == nil, discovery?.type == .model {
            do{
                toast = FancyToast(type: .info, title: FancyToastStyle.info.rawValue, message: Messages.modelLoadingInProgress, duration: -1)
                entity = try ModelEntity.load(contentsOf: placementObjectLocalPath)
            } catch {
                 toast = FancyToast(type: .error, title: FancyToastStyle.error.rawValue, message: Messages.modelLoadingFailed, duration: -1)
            }
        }
    }
    
    private func calculatePlaneSize(for markerSize: CGSize, and textureSize: CGSize) -> CGSize {
        let markerAspectRatio = markerSize.width / markerSize.height
        let textureAspectRatio = textureSize.width / textureSize.height
        
        if textureAspectRatio > markerAspectRatio {
            let planeWidth = markerSize.width
            let planeHeight = planeWidth / textureAspectRatio
            return CGSize(width: planeWidth, height: planeHeight)
        } else {
            let planeHeight = markerSize.height
            let planeWidth = planeHeight * textureAspectRatio
            return CGSize(width: planeWidth, height: planeHeight)
        }
    }
    
    func setUpLookingForText(){
        lookingForText.translatesAutoresizingMaskIntoConstraints = false
        lookingForText.textColor = .white.withAlphaComponent(0.7)
        lookingForText.textAlignment = .left
        lookingForText.font = UIFont.systemFont(ofSize: 18)
        lookingForText.font = UIFont.boldSystemFont(ofSize: 18)

        lookingForText.text = Messages.lookingForImageText
        lookingForText.layer.shadowColor = UIColor.black.cgColor
        lookingForText.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        lookingForText.layer.shadowOpacity = 0.5
        lookingForText.layer.shadowRadius = 1.0
        lookingForText.layer.masksToBounds = false
        view.addSubview(lookingForText)
        
        NSLayoutConstraint.activate([
            lookingForText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lookingForText.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -300)
        ])
    }
    
    func addMuteUnMuteButton(){
        muteUnMuteButton = UIButton(type: .custom)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize:  25, weight: .bold, scale: .large)
        let backImage = UIImage(systemName: Images.mute, withConfiguration: symbolConfig)
        muteUnMuteButton?.setImage(backImage, for: .normal)
        muteUnMuteButton?.tintColor = .white
        muteUnMuteButton?.addTarget(self, action: #selector(muteUnMuteButtonTapped), for: .touchUpInside)
        muteUnMuteButton?.translatesAutoresizingMaskIntoConstraints = false
        muteUnMuteButton?.layer.shadowColor = UIColor.black.cgColor
        muteUnMuteButton?.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        muteUnMuteButton?.layer.shadowOpacity = 0.5
        muteUnMuteButton?.layer.shadowRadius = 1.0
        muteUnMuteButton?.layer.masksToBounds = false
        view.addSubview(muteUnMuteButton!)
        
        let trailingConstraint: CGFloat = -16
        
        NSLayoutConstraint.activate([
            muteUnMuteButton!.topAnchor.constraint(equalTo: arView.safeAreaLayoutGuide.topAnchor, constant: 16),
            muteUnMuteButton!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingConstraint),
            muteUnMuteButton!.widthAnchor.constraint(equalToConstant: 40),
            muteUnMuteButton!.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    @objc func muteUnMuteButtonTapped() {
        player.isMuted = !player.isMuted
        updateMuteButtonImage()
    }
    func updateMuteButtonImage() {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize:  25, weight: .bold, scale: .large)
        let imageName = player.isMuted ? Images.unmute : Images.mute
        let muteUnMuteButtonImage = UIImage(systemName: imageName, withConfiguration: symbolConfig)
        muteUnMuteButton?.setImage(muteUnMuteButtonImage, for: .normal)
    }
}
