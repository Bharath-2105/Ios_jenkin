
import SwiftUI

struct OnboardEmailView: View {
    
    @State private var email : String = ""
    @Binding public var isLoading : Bool
    var onButtonPress: (String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center){
                HStack{
                    Image(Images.appImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 189, height: 141)
                        .foregroundStyle(Colors.adaptiveColor)
                    Spacer()
                    VStack(alignment: .trailing){
                        CustomText.InterBlackText(Constants.dcode, fontSize: .headingSubLarge,color: Colors.adaptiveColor)
                        CustomText.InterRegularText("v \(Bundle.main.object(forInfoDictionaryKey: Constants.CFBundleShortVersionString) as? String ?? Constants.unknown)", fontSize: .subHeadingMedium, color: Colors.adaptiveColor)
                    }
                }
                .padding(.vertical, 80)
                .padding(.horizontal, 20)
                CustomText.InterBlackText(Constants.login, fontSize: .headingSubLarge,color: Colors.adaptiveColor)
                Spacer().frame(height: 20)
                TextField("", text: $email,prompt: Text(Messages.enterYourEmail).foregroundColor(.gray).font(CustomText.InterRegularFont.subHeadingMedium.fontRegular))
                    .frame(height: 44)
                    .padding(.horizontal, 15)
                    .background(.gray.opacity(0.27))
                    .cornerRadius(8)
                    .foregroundColor(Colors.adaptiveColor)
                    .submitLabel(.return)
                    .keyboardType(.default)
                    .autocapitalization(.none)
                    .multilineTextAlignment(.leading)
                Spacer().frame(height: 16)
                StyledButton(label: Constants.continueText, width: geometry.size.width){
                    onButtonPress(email)
                }
                .showLoading($isLoading)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack{
        OnboardEmailView(isLoading: .constant(false)) { email in
            print(email)
        }
    }.background(.gray)

}
