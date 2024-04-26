import SwiftUI

struct NetworkUnavailableView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Image(Images.networkLostLogo)
                    .foregroundStyle(Colors.adaptiveColor)
                Spacer().frame(height: 12)
                CustomText.InterBlackText(Messages.networkLostTitle, fontSize: .subHeadingLarge,color: Colors.adaptiveColor)
                CustomText.InterRegularText(Messages.networkLostMessage, fontSize: .subHeadingMedium,color: Colors.adaptiveColor.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.adaptiveBackground)
    }
}

#Preview {
    NetworkUnavailableView()
}
