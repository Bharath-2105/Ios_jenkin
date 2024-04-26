import SwiftUI
@main
struct DCodeAppClipApp: App {
    
    @StateObject private var dcodeModel = DCodeModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State var toast: FancyToast? = nil
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                DCodeAppClipScanView(dismiss: .constant(false))
                    .environmentObject(dcodeModel)
                    .environmentObject(networkMonitor)
                    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                        if let incomingURL = userActivity.webpageURL {
                            dcodeModel.setScannedUrl(url: incomingURL, onSuccess: {
                                toast = nil
                            }, onFailure: { error in
                                print(error)
                                toast = FancyToast(type: .error, title: FancyToastStyle.error.rawValue, message: error, duration: -1)
                            })
                            print(Messages.appClipLaunchMessage + "\(incomingURL)")
                        }
                    }
                    .onAppear(){
                        FileCache.shared.setupFileCache()
                    }
                    .toastView(toast: $toast)
                    .edgesIgnoringSafeArea(.all)
                if !(networkMonitor.isConnected ?? true) {
                    NetworkUnavailableView()
                }
            }
        }
    }
}

