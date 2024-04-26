import SwiftUI

struct NonARViewContainer: View {
    var discovery: Discovery?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var urlString: String? = nil
    @State var toast: FancyToast? = nil
    @State var showSaveButton: Bool = false
    @State private var colorScheme: ColorScheme? = nil

    var isFromScanTab: Bool?
    
    var body: some View {
        ZStack{
            VStack {
                if let discovery = self.discovery{
                    switch discovery.type{
                    case .video:
                        VideoPlayerView(videoURL: discovery.mediaInfo)

                    case .image:
                        ImageViewerView(imageUrl: discovery.mediaInfo)
                        
                    case .model:
                        ModelViewContainer(modelUrl: discovery.threeDModelUsdz , discoveryType: discovery.type!, colorScheme: $colorScheme)
                        
                    case .pdf:
                        PDFViewController(pdfUrl: discovery.pdfUrl)
                        
                    case .web:
                        WebViewController(link: discovery.webLink)
                        
                    default:
                        EmptyView()
                    }
                }
            }
            
            if presentationMode.wrappedValue.isPresented {
                VStack{
                    HStack{
                        Button{
                            presentationMode.wrappedValue.dismiss()
                            colorScheme = nil
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
                .padding(.top, 67)
            }
        }
        .toastView(toast: $toast)
        .preferredColorScheme(colorScheme)
    }
}

