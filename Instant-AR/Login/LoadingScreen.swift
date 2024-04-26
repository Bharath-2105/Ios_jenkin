import SwiftUI

struct LoadingScreen: View {
    @State private var showLoading: Bool = false
    var body: some View {
        ZStack {
            Image(Images.launchScreen)
                .resizable()
                .scaledToFill()
                .scaleEffect(1.09)
        }
        .ignoresSafeArea(.all)
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
    }
}
