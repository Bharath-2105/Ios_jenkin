import SwiftUI
import Kingfisher

struct SavedDiscoveryView: View {
    @State private var isPresentingDiscovery = false
    @State private var isSelected: Bool = false
    @Binding var toast: FancyToast?
    @Binding var isSelectionEnabled: Bool
    @Binding var itemsToDelete: [String]
    
    var discovery: Discovery
    
    var body: some View {
        GeometryReader{ geometry in
            Color.theme.adaptiveBackground
            ZStack{
                if discovery.logoImage.count > 0{
                    KFImage(URL(string: discovery.logoImage))
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [.clear,.clear,.clear,.clear, .black.opacity(0.32)]),
                                           startPoint: .top,
                                           endPoint: .bottom)
                            .cornerRadius(8)
                        )
                }
                VStack{
                    HStack{
                        if isSelectionEnabled{
                            if isSelected{
                                ZStack{
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 20, height: 20)
                                    Image(systemName: Images.checkmarkIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(.blue)
                                        .frame(width: 20, height: 20)
                                }
                            } else{
                                Circle()
                                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
                                    .frame(width: 20, height: 20)
                                    .shadow(color: Color.black.opacity(0.3), radius: 1)
                            }
                        }
                        Spacer()
                        ZStack{
                            if let type = discovery.type{
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.black.opacity(0.20))
                                    .blur(radius: 1)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                Image(getDefaultIcon(type: type))
                            }
                        }
                    }
                    Spacer()
                    HStack{
                        CustomText.InterSemiBoldText(discovery.name,fontSize: .subHeadingLarge, color: .white.opacity(0.6))
                        Spacer()
                    }
                    
                }
                .padding(.all, 8)
            }
            .frame(width: geometry.size.width, height: geometry.size.width)
            .onTapGesture {
                if isSelectionEnabled{
                    self.isSelected.toggle()
                    if itemsToDelete.contains(discovery.id){
                            itemsToDelete.removeAll(where: {$0 == discovery.id})
                        } else{
                            itemsToDelete.append(discovery.id)
                        }
                    
                } else{
                    isPresentingDiscovery = true
                }
            }
            .navigationDestination(isPresented: $isPresentingDiscovery) {
                NonARViewContainer(discovery: discovery)
                    .ignoresSafeArea(.all)
                    .navigationBarBackButtonHidden(true)

            }
            .onChange(of: isSelectionEnabled) { newValue in
                if !isSelectionEnabled{
                    self.isSelected = false
                }
            }
        }
    }
    
    func getDefaultIcon(type: DiscoveryType)-> String{
        switch type {
        case .video:
            return Images.defaultVideoIcon
        case .image:
            return Images.defaultImageIcon
        case .model:
            return Images.default3DIcon
        case .pdf:
            return Images.defaultPdfIcon
        case .web:
            return Images.defaultWebLinkIcon
        default:
            break
        }
        return ""
    }
}
