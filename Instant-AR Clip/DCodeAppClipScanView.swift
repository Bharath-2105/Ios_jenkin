import SwiftUI
import RealityKit

struct DCodeAppClipScanView: View {
    @EnvironmentObject var dcodeModel: DCodeModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var dismiss: Bool
    
    var body: some View {
        ZStack {
            if let discovery = dcodeModel.discovery{
                if discovery.arMode {
                    if !dcodeModel.isCameraAccessDenied {
                        ImageTrackingViewContainer(discovery: discovery)
                            .onAppear(perform: {
                                checkCameraPermission(completion: {  isCameraAccessDenied in
                                    DispatchQueue.main.async {
                                        dcodeModel.isCameraAccessDenied = isCameraAccessDenied
                                    }
                                })
                            })
                    } else {
                        CameraUnavailableView(text: Messages.enableCameraForImmersiveText)
                    }
                } else{
                    NonARViewContainer(discovery: discovery)
                        .ignoresSafeArea(.all)
                }
                
                if checkAppStatus(){
                    SaveButtonView()
                }

            } else {
                VStack {
                    ProgressView() // Loading indicator
                        .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                        .scaleEffect(1) // Adjust size as needed
                        .padding(.bottom, 20) // Adds space between the indicator and the text
                    CustomText.InterRegularText(Messages.fetchingDCodeDetailsMessage, fontSize: .subHeadingLarge, color: Colors.adaptiveColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding() // Add padding around the VStack content for better readability
            }
            
            if presentationMode.wrappedValue.isPresented &&  dcodeModel.discovery?.arMode == true{
                VStack{
                    HStack{
                        Button{
                            presentationMode.wrappedValue.dismiss()
                        }label: {
                            Image(systemName: Images.chevronLeft)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 1.0, x: 1.0, y: 1.0)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 70)
            }
           
        }
        .onChange(of: dismiss, perform: { newValue in
            if newValue {
                presentationMode.wrappedValue.dismiss()
            }
        })
        .onAppear(perform: {
            if dcodeModel.discovery == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppNotifications.stopCaptureSession) , object: nil)
            }
        })
    }
    
    func checkAppStatus() -> Bool {
        guard let mainAppURL = URL(string: Constants.mainAppURLScheme),
              UIApplication.shared.canOpenURL(mainAppURL) else {
            return true            // App Uninstall case

        }
        if let _ = SharedUserDefaults.shared.getValue(forKey: userDefaultsKey.accessToken.rawValue) as? String {
            return false           // User is logged in
        } else {
            return true            // Logout case

        }
    }
}

#Preview {
    DCodeAppClipScanView(dismiss: .constant(false))
}

struct SaveButtonView: View {
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Spacer()
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(height: 65)
                    HStack{
                        Image(Images.appIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .cornerRadius(10)
                        VStack(alignment: .leading){
                            CustomText.InterBoldText(Messages.saveDisovery, fontSize: .subHeadingLarge, color: .black)
                            CustomText.InterRegularText(checkAppInstallationStatus() ? Messages.loginToSave : Messages.installAppToSave, fontSize: .subHeadingMedium, color: .black.opacity(0.6))
                        }
                        Spacer()
                        Image(systemName: Images.chevronRight)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                }
                .onTapGesture {
                    saveDiscoveryFromAppClip()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
    }
    
    func checkAppInstallationStatus()-> Bool{
        guard let mainAppURL = URL(string: Constants.mainAppURLScheme),
              UIApplication.shared.canOpenURL(mainAppURL) else {
            return false
        }
        return true
    }
    
    func saveDiscoveryFromAppClip(){
        if let mainAppURL = URL(string: Constants.mainAppURLScheme), UIApplication.shared.canOpenURL(mainAppURL) {
            UIApplication.shared.open(mainAppURL, options: [:], completionHandler: nil)
        } else{
            guard let url = URL(string: Constants.bundleIdLookupUrl + Constants.mainAppBundleId) else {
                return
            }
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                guard let data = data else {
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = json[Constants.results] as? [[String: Any]],
                       let firstResult = results.first,
                       let _appStoreUrl = firstResult[Constants.trackViewUrl] as? String {
                        let appStoreURL = URL(string: _appStoreUrl)
                        if let appStoreURL = appStoreURL {
                            DispatchQueue.main.async {
                                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                            }
                        }
                    }
                } catch {
                    print(Messages.jsonDeserializeFailure, error)
                }
            }.resume()
        }
    }
}

