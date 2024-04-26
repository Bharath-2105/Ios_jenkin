import SwiftUI
import RealityKit
import ARKit


struct ModelViewContainer: View {
    @EnvironmentObject var dcodeModel: DCodeModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var selectedOption = 0
    @State private var localModelPath : String? = nil
    @State private var downloadProgress : Int = 0
    var modelUrl: String
    var discoveryType: DiscoveryType
    @Binding var colorScheme: ColorScheme?

    var body: some View {
        ZStack(alignment: .top) {
            if(localModelPath != nil){
                switch selectedOption {
                case 0:
                    if !dcodeModel.isCameraAccessDenied {
                        ARModelView(localFilePath: localModelPath, discoveryType: discoveryType)
                    } else {
                        CameraUnavailableView(text: Messages.enableCameraForImmersiveText)
                    }
                case 1:
                    ModelView(localFilePath: localModelPath)
                default:
                    EmptyView()
                }
                
                HStack {
                    Picker("", selection: $selectedOption) {
                        CustomText.InterRegularText(Constants.ar, fontSize: .body, color: .black).tag(0)
                        CustomText.InterRegularText(Constants.classic, fontSize: .body, color: .black).tag(1)
                    }
                    .frame(width: 150)
                    .pickerStyle(SegmentedPickerStyle())
                    .cornerRadius(5)
                }
                .padding(.top, 70)
                
            } else {
                VStack{
                    StyledButton(label: "", width: 40){
                    }
                    .showLoading(.constant(true))
                    CustomText.InterBoldText(Messages.fetching3DModel, fontSize: .subHeadingMedium, color: .black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
        }
        .onChange(of: selectedOption, perform: { newValue in
            colorScheme = newValue == 0 ? .light : dcodeModel.isCameraAccessDenied ? nil : .light
            if !dcodeModel.isCameraAccessDenied && newValue == 1 {
                checkCameraPermission(completion: {  isCameraAccessDenied in
                    DispatchQueue.main.async {
                        if isCameraAccessDenied {
                            dcodeModel.isCameraAccessDenied = isCameraAccessDenied
                            colorScheme = nil
                        }
                    }
                })
            }
        })
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(){
            colorScheme = .light
            if let fileUrl = FileCache.shared.getCachedFile(for: modelUrl){
                localModelPath = fileUrl.absoluteString
            }
        }
        .onDownloadNotification(completion: { urlString , localFilePath in
            localModelPath = localFilePath
        }, progress: { urlString, progressValue in
            downloadProgress = progressValue
        })
         .preferredColorScheme(colorScheme)
         .background(.black)
    }
}
