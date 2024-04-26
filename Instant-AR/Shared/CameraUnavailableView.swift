import SwiftUI

struct CameraUnavailableView: View {
    var text: String
    var body: some View {
        VStack {
            CustomText.InterBlackText(text, fontSize: .subHeadingLarge, color: Colors.adaptiveColor)
                .multilineTextAlignment(.center)
            Spacer().frame(height: 30)
            if let bundleID = Bundle.main.bundleIdentifier, bundleID.contains(Constants.clip) {
                CustomText.InterRegularText(Messages.navigateToSettingsText, fontSize: .subHeadingMedium, color: Colors.adaptiveColor)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 30)
            }
            StyledButton(label: Constants.settings, action: {
                openSettings()
            })
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
