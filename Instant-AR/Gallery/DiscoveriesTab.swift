import SwiftUI

struct DiscoveriesTab: View {
    @EnvironmentObject var dcodeModel: DCodeModel
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showLogOutConfirmationAlert: Bool = false
    @State private var showDeleteConfirmationAlert: Bool = false
    @State private var isSelectionEnabled: Bool = false
    @State var infoUrl: String?
    @State var toast: FancyToast? = nil
    @State var itemsToDelete: [String] = []
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        GeometryReader{ geometry in
            let gridFrame = geometry.size.width / 2 - 24
            ZStack{
                VStack{
                    ZStack(alignment: .bottom){
                        HStack{
                            CustomText.InterBoldText(Constants.discoveries, fontSize: .headingLarge,color: Colors.adaptiveColor)
                            Image(Images.discoveriesImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Spacer()
                            if isSelectionEnabled{
                                Button{
                                    self.itemsToDelete.removeAll()
                                    isSelectionEnabled = false
                                }label: {
                                    Image(Images.closeButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .scaleEffect(0.8)
                                        .foregroundStyle(Colors.adaptiveColor)
                                }
                                Spacer().frame(width: 25)
                            }
                            Button(action: {
                                if isSelectionEnabled{
                                    if itemsToDelete.isEmpty{
                                        toast = FancyToast(type: .info, title: FancyToastStyle.info.rawValue, message: Messages.selectAtleastOneItem, duration: 4)
                                    } else{
                                        showDeleteConfirmationAlert = true
                                    }
                                    
                                } else{
                                    if  dcodeModel.savedDiscoveries.count == 0{
                                        self.isSelectionEnabled = false
                                        toast = FancyToast(type: .info, title: FancyToastStyle.info.rawValue, message: Messages.noDiscoveriesFound)
                                    } else{
                                        isSelectionEnabled = true
                                    }
                                }
                            }) {
                                Image(isSelectionEnabled ? Images.deleteButton : Images.selectionButton)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Colors.adaptiveColor)
                            }
                            .confirmationDialog(Constants.delete, isPresented: $showDeleteConfirmationAlert) {
                                Button(Constants.delete) {
                                    if itemsToDelete.count != 0{
                                        dcodeModel.deleteDiscovery(itemId: itemsToDelete) { result in
                                            DispatchQueue.main.async {
                                                self.isSelectionEnabled = false
                                            }
                                        } onFailure: { error in
                                            toast = FancyToast(type: .error, title: Messages.errorInDeletion, message: error, duration: 4)
                                        }
                                        itemsToDelete.removeAll()
                                    }
                                }
                            }message: {
                                Text(Messages.deletionConfirmationText)
                            }
                        }
                        .padding([.horizontal, .top])
                    }
                    
                    Spacer().frame(height: 15)
                    if dcodeModel.savedDiscoveries.count == 0{
                        Spacer()
                        CustomText.InterRegularText(Messages.noDiscoveriesYet, fontSize: .subHeadingMedium, color: .gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        Spacer().frame(height: geometry.size.height * 0.5)
                    } else{
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(0..<dcodeModel.savedDiscoveries.count, id: \.self) { index in
                                    SavedDiscoveryView(toast: $toast, isSelectionEnabled: $isSelectionEnabled, itemsToDelete: $itemsToDelete, discovery:  dcodeModel.savedDiscoveries[index])
                                        .frame(width: gridFrame, height: gridFrame)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .background(Color.theme.adaptiveBackground)
                .toastView(toast: $toast)
                if toast != nil{
                    Spacer().frame(height: 90)
                }
            }
            .ignoresSafeArea(edges: [.horizontal])
        }
    }
}

#Preview {
    DiscoveriesTab()
}
