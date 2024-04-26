import SwiftUI
import AVFoundation

@main
struct Instant_ARApp: App {
    @StateObject private var dcodeModel = DCodeModel()
    @StateObject var userViewModel = UserViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var wasInBackground = false
    @Environment(\.scenePhase) var scenePhase
    let receivedForbidden = NotificationCenter.default.publisher(for: .receivedForbidden)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var toast: FancyToast? = nil

    var body: some Scene {
        WindowGroup {
            OnboardingScreen()
                .environmentObject(dcodeModel)
                .environmentObject(userViewModel)
                .environmentObject(networkMonitor)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    if let incomingURL = userActivity.webpageURL {
                        dcodeModel.setScannedUrl(url: incomingURL, onSuccess: {
                            toast = nil
                            dcodeModel.incomingUrlFromAppClip = incomingURL
                        }, onFailure: { _ in
                            toast = FancyToast(type: .error, title: FancyToastStyle.error.rawValue, message: Messages.invalidQRCode, duration: 4)
                        })
                    }
                }
                .onAppear(){
                    FileCache.shared.setupFileCache()
                    userViewModel.checkAuthenticationStatus(
                        onSuccess:{
                            dcodeModel.saveUnSavedDiscovery()
                            dcodeModel.getSavedDiscoveris()
                        })
                }
                .onReceive(receivedForbidden) { _ in
                    userViewModel.checkAuthenticationStatus(silent:true, onSuccess: {
                    })
                }
                .toastView(toast: $toast)
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .background:
                wasInBackground = true
                dcodeModel.incomingUrlFromAppClip = nil
            case .active:
                if wasInBackground {
                    if let isConnected = networkMonitor.isConnected, isConnected {
                        userViewModel.checkAuthenticationStatus(silent:true, onSuccess: {
                            dcodeModel.saveUnSavedDiscovery()
                        })
                    }
                    wasInBackground = false
                }
            default:
                break
            }
        }
    }
}
extension Notification.Name {
    static let receivedForbidden = Notification.Name(AppNotifications.receivedForbidden)
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            UIApplication.shared.connectedScenes.forEach { scene in
                if let windowScene = scene as? UIWindowScene {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                }
            }
        }
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    func updateUIViewController(_ uiViewController: UIViewController) {
        uiViewController.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
}

