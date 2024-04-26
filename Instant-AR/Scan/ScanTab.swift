import SwiftUI
import Kingfisher

struct ScanTab: View {
    @EnvironmentObject var dcodeModel: DCodeModel
    @State var navigateToARViewContainer: Bool = false
    @State private var scannedCode: String?
    @State private var refreshUUID = UUID()
    @State var toast: FancyToast? = nil
    @State var dismissScannedCodeView: Bool = false
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                if !dcodeModel.isCameraAccessDenied {
                    QRCodeScannerView { code in
                        if scannedCode == nil{
                            self.navigateToARViewContainer = true
                        }
                        self.scannedCode = code
                    }
                    
                    if scannedCode == nil {
                        VStack{
                            Image(Images.qrScanIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .shadow(color: .black, radius: 1.0, x: 1.0, y: 1.0)
                            CustomText.InterBoldText(Messages.pointYourCamera, fontSize: .subHeadingLarge, color: .white)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black, radius: 1.0, x: 1.0, y: 1.0)
                            
                        }
                        .opacity(0.7)
                        .padding(.horizontal, 50)
                    }
                } else {
                    CameraUnavailableView(text: Messages.enableCameraToScanText)
                }
                
            }
            .id(refreshUUID)
            .edgesIgnoringSafeArea([.top,.leading,.trailing])
            .navigationDestination(isPresented: $navigateToARViewContainer) {
                DCodeAppClipScanView(dismiss: $dismissScannedCodeView)
                    .onAppear{
                        if let scannedUrl = self.scannedCode, let url = URL(string: scannedUrl), dcodeModel.incomingUrlFromAppClip == nil {
                            dcodeModel.setScannedUrl(url: url, onSuccess: {
                            }, onFailure: { error in
                                self.dismissScannedCodeView = true
                            })
                        }
                    }
                    .ignoresSafeArea(.all)
                    .navigationBarBackButtonHidden(true)
            }
            .onChange(of: navigateToARViewContainer) { newValue in
                if !navigateToARViewContainer{
                    dcodeModel.discovery = nil
                    dcodeModel.incomingUrlFromAppClip = nil
                    if dismissScannedCodeView {
                        toast = FancyToast(type: .error, title: FancyToastStyle.error.rawValue, message: Messages.invalidQRCode, duration: 4)
                        self.dismissScannedCodeView = false
                    }
                    self.scannedCode = nil
                    self.refreshUUID = UUID()
                }
            }
            .toastView(toast: $toast)
            .background(Color.theme.adaptiveBackground)
            .onAppear{
                self.refreshUUID = UUID()
                navigateToARViewContainerFromAppClip()
                checkCameraPermission(completion: {  isCameraAccessDenied in
                    DispatchQueue.main.async {
                        dcodeModel.isCameraAccessDenied = isCameraAccessDenied
                    }
                 })
            }
            .onChange(of: dcodeModel.incomingUrlFromAppClip) { newValue in
                navigateToARViewContainerFromAppClip()
            }
            .onDisappear{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppNotifications.stopCaptureSession) , object: nil)
            }
        }
    }
    func navigateToARViewContainerFromAppClip() {
        if let _ = dcodeModel.incomingUrlFromAppClip {
            navigateToARViewContainer = true
        }
    }
}

#Preview {
    ScanTab()
}
