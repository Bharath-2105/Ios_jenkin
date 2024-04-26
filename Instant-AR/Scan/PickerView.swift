import SwiftUI
import RealityKit
import ARKit

struct PickerView: View {
    @EnvironmentObject var infoViewModel: InfoViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isModelLoaded: Bool = false
    @State private var selectedOption = 0
    @State private var urlString: String?
    var isFromGalleryTab: Bool = false
    var isFromScanTab: Bool = false
    var isFromAppClip: Bool = false
    var savedInfo: SavedInfo?
    var scannedInfo: Info?

    var body: some View {
        ZStack(alignment: .top) {
            switch selectedOption {
            case 0:
                ARViewContainer(scannedURL: scannedInfo, isFromScanTab: isFromScanTab, isFromGalleryTab: isFromGalleryTab,isFromAppClip: isFromAppClip, savedInfo: savedInfo)
            case 1:
                ARModelView(threeDModelUrl: isFromScanTab || isFromAppClip ? scannedInfo?.threeDModelUsdz : savedInfo?.threeDModelUsdz)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                EmptyView()
            }
            if !isFromAppClip{
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(selectedOption == 0 ? .white : .gray.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.top, 70)
                .padding(.leading, 20)
            }
            if isModelLoaded{
                HStack {
                    Picker("Select View", selection: $selectedOption) {
                        Text("AR").tag(0)
                        Text("Object").tag(1)
                    }
                    .frame(width: 150)
                    .pickerStyle(SegmentedPickerStyle())
                    .background(.white.opacity(0.2))
                    .cornerRadius(5)
                }
                .padding(.top, 70)
            } else{
                VStack{
                    StyledButton(label: "", width: 40){
                    }
                    .showLoading(.constant(true))
                    Text("Fetching your 3D experience... Please hold on!")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, UIScreen.main.bounds.height * 0.45)
            }
        }
        .onAppear{
            if isFromGalleryTab {
                urlString = savedInfo?.threeDModelUsdz
            } else  {
                urlString = scannedInfo?.threeDModelUsdz
            }
            if let url = URL(string: urlString ?? ""){
                FileDownloader.downloadFile(from: url) { _, _ in
                    self.isModelLoaded = true
                }
            }
        }
        .onChange(of: selectedOption, perform: { newValue in
            if newValue == 0{
                self.isModelLoaded = false
                if let urlString = urlString, let url = URL(string: urlString){
                    FileDownloader.downloadFile(from: url) { _, _ in
                        self.isModelLoaded = true
                    }
                }
            }
        })
        .navigationBarBackButtonHidden()
        .preferredColorScheme(.light)
    }
}
