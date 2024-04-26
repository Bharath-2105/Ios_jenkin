import SwiftUI
import AVFoundation
import ARKit
struct QRCodeScannerView: UIViewControllerRepresentable {
    @EnvironmentObject var dcodeModel: DCodeModel
    let captureSession = AVCaptureSession()
    var didScanOnce: Bool = true
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerView

        init(parent: QRCodeScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                parent.didFindCode(stringValue)
                if parent.didScanOnce {
                    let feedbackGenerator = UINotificationFeedbackGenerator()
                    feedbackGenerator.notificationOccurred(.success)
                    parent.didScanOnce = false
                }
            }
        }
    }

    var didFindCode: (String) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        
        do {
            try videoCaptureDevice.lockForConfiguration()
            if videoCaptureDevice.isFocusModeSupported(.continuousAutoFocus) {
                videoCaptureDevice.focusMode = .continuousAutoFocus
            }
            videoCaptureDevice.unlockForConfiguration()
        } catch {
            print(Messages.autoFocusConfigureError + "\(error)")
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return viewController }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        previewLayer.frame = CGRect(x: 0, y: 0, width: viewController.view.bounds.width, height: UIScreen.main.bounds.height)

        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        DispatchQueue.global().async {
            captureSession.startRunning()
        }

        if let observer = dcodeModel.observer {
            NotificationCenter.default.removeObserver(observer)
        }
        self.dcodeModel.observer = NotificationCenter.default.addObserver(forName: Notification.Name(AppNotifications.stopCaptureSession), object: nil, queue: nil) { notification in
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                previewLayer.removeFromSuperlayer()
            }
        }
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            try videoCaptureDevice.lockForConfiguration()
            if videoCaptureDevice.isFocusModeSupported(.continuousAutoFocus) {
                videoCaptureDevice.focusMode = .continuousAutoFocus
            }
            videoCaptureDevice.unlockForConfiguration()
        } catch {
            print(Messages.autoFocusConfigureError + "\(error)")
        }
    }
}
