
import SwiftUI

struct OnboardOTPView: View {
    @State private var otp : String = ""
    @Binding public var isLoading : Bool
    @Binding var showWrongOtpInputView: Bool
    @State var focusState: FocusPin?
    var onButtonPress: (String) -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading){
                Spacer().frame(height: 100)
                CustomText.InterBlackText(Constants.verification, fontSize: .headingSubLarge,color: Colors.adaptiveColor)
                Spacer().frame(height: 6)
                CustomText.InterRegularText(Messages.enterOtp, fontSize: .subHeadingMedium,color: .gray)
                Spacer().frame(height: 16)
                OtpFormFieldView(otpValue: $otp, showWrongOtpInputView: $showWrongOtpInputView, focusState: $focusState)
                    .padding(.leading, 5)
                if showWrongOtpInputView {
                    Spacer().frame(height: 15)
                    CustomText.InterBoldText(Messages.wrongOtp, fontSize: .subHeadingMedium,color: .red)
                }
                Spacer()

            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
            .onChange(of: otp.count) { newCount in
                if otp.count == 4 {
                    onButtonPress(otp)
                }
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

enum FocusPin {
    case  pinOne, pinTwo, pinThree, pinFour
}

