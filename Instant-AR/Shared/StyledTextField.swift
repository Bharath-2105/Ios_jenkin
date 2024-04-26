import SwiftUI

struct StyledTextField: View {
    @Binding var text: String
    @Binding var bgBorderColor: Color
    var LineWidth: CGFloat
    var placeholder: String = ""
    var font: Font = CustomText.InterRegularFont.subHeadingLarge.fontRegular
    var background: Color = .white
    var foreground: Color = .primary
    var placeholderColor: Color = .red
    var submitLabel: SubmitLabel = .return
    var keyboardType: UIKeyboardType = .default
    var alignment: TextAlignment = .leading
    var autocapitalization : UITextAutocapitalizationType = .none
    var height: CGFloat = 44
    var width: CGFloat = 46
    
    var body: some View {
        TextField("", text: $text,prompt: Text(placeholder).foregroundColor(placeholderColor))
            .frame(width: width, height: height)
            .frame(width: 75, height: 75)
            .keyboardType(keyboardType)
            .background(.clear)
            .cornerRadius(8)
            .font(font)
            .foregroundColor(foreground)
            .submitLabel(submitLabel)
            .multilineTextAlignment(.center)
            .accentColor(.primary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.5)
                    .stroke(bgBorderColor, lineWidth: LineWidth)
            )
        
    }
}
