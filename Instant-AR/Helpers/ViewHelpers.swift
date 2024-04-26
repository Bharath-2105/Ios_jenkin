import Foundation
import AVFoundation
import UIKit

func checkCameraPermission(completion: @escaping ((Bool)->())) {
    let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    if cameraStatus == .notDetermined {
        AVCaptureDevice.requestAccess(for: .video) { permission in
            completion(!permission)
        }
    } else if cameraStatus == .denied || cameraStatus == .restricted {
        completion(true)
    } else {
        completion(false)
    }
}

func openSettings() {
    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingsURL)
    }
}
