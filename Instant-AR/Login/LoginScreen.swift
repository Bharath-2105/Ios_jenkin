import SwiftUI

struct LoginScreen: View {
    
    @State var isEmailFilled: Bool = false
    @State private var otp: String = ""
    @State private var userEmail: String = ""
    @State private var isLoading : Bool = false
    @State var showWrongOtpInputView: Bool = false
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var dcodeModel: DCodeModel
    
    @State private var toast: FancyToast? = nil
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack(alignment: .top){
                Image(Images.loginBackgroundImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack{
                    if !isEmailFilled {
                        OnboardEmailView(isLoading: $isLoading) { email in
                            sendOTP(email: email)
                            
                        }
                    } else {
                        OnboardOTPView(isLoading: $isLoading, showWrongOtpInputView: $showWrongOtpInputView) { otpValue in
                            self.otp = otpValue
                        }
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.55)
            }
            .toastView(toast: $toast)
            .onChange(of: otp) { newValue in
                if otp.count == 4{
                    verifyOTP(email: self.userEmail, otp: otp)
                }
            }
        }
    }
    
    func sendOTP(email:String){
        isLoading = true
        userViewModel.sendOtp(email: email) { auth in
            self.userEmail = email
            isEmailFilled = true
            isLoading = false
        } onFailure: { error in
            isLoading = false
            toast = FancyToast(type: .error, title: FancyToastStyle.error.rawValue, message: error, duration: 4)
        }
    }
    
    func verifyOTP(email:String, otp:String){
        isLoading = true
        userViewModel.verifyOtp(otp: otp, email: email) { auth in
            userViewModel.checkAuthenticationStatus(onSuccess:{
                dcodeModel.saveUnSavedDiscovery()
                dcodeModel.getSavedDiscoveris()
            })
        } onFailure: { error in
            isLoading = false
            self.showWrongOtpInputView = true
            toast = FancyToast(type: .error, title: FancyToastStyle.error.rawValue, message: error, duration: 4)
        }
    }
    
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}
