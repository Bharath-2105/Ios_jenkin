import SwiftUI

struct ProfileTab: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showLogOutConfirmationAlert: Bool = false
    @State private var showAccountDeleteConfirmation: Bool = false
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    CustomText.InterBoldText(Constants.profile, fontSize: .headingLarge,color: Colors.adaptiveColor)
                    Spacer()
                    Button {
                        self.showLogOutConfirmationAlert = true
                    } label: {
                        Image(Images.logoutButton)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Colors.adaptiveColor)
                    }
                }
                .padding(.top)
                
                Divider()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                HStack{
                    CustomText.InterRegularText(Constants.email.capitalized, fontSize: .subHeadingMedium,color: Colors.adaptiveColor)
                    Spacer()
                    Image(systemName: Images.person)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.gray)
                    CustomText.InterRegularText(userViewModel.user?.email ?? "", fontSize: .subHeadingMedium,color: .gray)
                }
                Spacer()
                Button {
                    self.showAccountDeleteConfirmation = true
                } label: {
                    ZStack{
                        Colors.adaptiveColor.opacity(0.12)
                        CustomText.InterBlackText(Constants.deleteAccount, fontSize: .subHeadingMedium,color: Colors.adaptiveColor)
                    }
                    .frame(height: 45)
                }
                .cornerRadius(8)
                Spacer().frame(height: 15)
            }
            .padding(.horizontal)
            VStack {
                Image(Images.appImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 75)
                    .foregroundStyle(Colors.adaptiveColor)
                Spacer().frame(height: 20)
                CustomText.InterBlackText(Constants.dcode, fontSize: .subHeadingLarge,color: .gray)
                CustomText.InterRegularText("v \(Bundle.main.object(forInfoDictionaryKey: Constants.CFBundleShortVersionString) as? String ?? Constants.unknown)", fontSize: .subHeadingMedium, color: .gray)
                Spacer().frame(height: 20)
                CustomText.InterRegularText(Messages.profileCaption, fontSize: .subHeadingMedium,color: .gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            VStack {
                Spacer()
                CustomText.InterRegularText(Constants.poweredBy, fontSize: .body, color: .gray)
                Image(Images.TALogo)
                Spacer().frame(height: UIScreen.main.bounds.height * 0.17)
            }
        }
        .background(Color.theme.adaptiveBackground)
        .ignoresSafeArea(edges: [.horizontal])
        .confirmationDialog(Constants.logout, isPresented: $showLogOutConfirmationAlert) {
            Button(Constants.logout) {
                SharedUserDefaults.shared.removeValue(forKey: userDefaultsKey.accessToken.rawValue)
                SharedUserDefaults.shared.removeValue(forKey: userDefaultsKey.refreshToken.rawValue)
                SharedUserDefaults.shared.set(value: false, forKey: userDefaultsKey.isLoggedIn.rawValue)
                userViewModel.checkAuthenticationStatus()
            }
        }message: {
            Text(Messages.logoutConfirmation)
        }
        .confirmationDialog(Constants.deleteAccount, isPresented: $showAccountDeleteConfirmation) {
            Button(Constants.deleteAccount) {
                userViewModel.deleteUser { success in
                    SharedUserDefaults.shared.removeValue(forKey: userDefaultsKey.accessToken.rawValue)
                    SharedUserDefaults.shared.removeValue(forKey: userDefaultsKey.refreshToken.rawValue)
                    SharedUserDefaults.shared.set(value: false, forKey: userDefaultsKey.isLoggedIn.rawValue)
                    userViewModel.checkAuthenticationStatus()
                } onFailure: { error in
                    print(error)
                }
            }
        }message: {
            Text(Messages.accountDeletionConfirmation)
        }
    }
}

#Preview {
    ProfileTab()
}
