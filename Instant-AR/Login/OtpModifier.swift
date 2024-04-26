import SwiftUI
import Combine

struct OtpModifer: ViewModifier {
    
    @Binding var pin : String
    var textLimt = 1
    func limitText(_ upper : Int) {
        if pin.count > upper {
            self.pin = String(pin.prefix(upper))
        }
    }
    func body(content: Content) -> some View {
        content
            .frame(width: 50)
            .onReceive(Just(pin)) {_ in limitText(textLimt)}
    }
}
