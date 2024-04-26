import SwiftUI

struct OnboardingScreen: View {
   @EnvironmentObject var userViewModel: UserViewModel
   @EnvironmentObject var networkMonitor: NetworkMonitor
   @EnvironmentObject var dcodeModel: DCodeModel

   var body: some View {
      ZStack {
          if userViewModel.isAuthenticating {
              LoadingScreen()
          } else if userViewModel.isAuthenticated {
              HomeScreen()
          } else {
              LoginScreen()
                  .ignoresSafeArea(.all)
          }
          if let isConnected = networkMonitor.isConnected, !isConnected {
              NetworkUnavailableView()
          }
      }
      .onChange(of: networkMonitor.isConnected ?? false) { newValue in
          if newValue {
              userViewModel.checkAuthenticationStatus(silent:true, onSuccess: {
                  dcodeModel.saveUnSavedDiscovery()
                  dcodeModel.getSavedDiscoveris()
              })
          }
      }
   }
}

#Preview {
    OnboardingScreen()
}
