

import SwiftUI

struct StyledButton: View {
    var label:String
    var background: Color = Colors.adaptiveColor
    var textColor: Color = Color.theme.adaptiveBackground
    var width: CGFloat = 114
    var height: CGFloat = 44
    var action: () -> Void
    
    var body: some View {
        ZStack{
            Button (action:action, label: {
                ZStack{
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: width, height: height)
                        .background(background)
                        .cornerRadius(8)
                    CustomText.InterBlackText(label, fontSize: .subHeadingLarge, color: textColor)
                }
            })
        }
        
    }
    
}

struct LoadingModifier: ViewModifier {
    @Binding var isLoading: Bool
    let background: Color
    let textColor: Color
    let width: CGFloat
    let height: CGFloat
    var action: () -> Void
    
    func body(content: Content) -> some View {
        
            if isLoading {
                ZStack {
                    Circle()
                        .cornerRadius(22)
                        .foregroundColor(background)
                        .frame(width: width, height: height)
                        .background(.clear)
                    DynamicLoader(color: textColor)
                }
            } else {
                content
            }
    }
}


extension StyledButton {
    func showLoading(_ isLoading: Binding<Bool>) -> some View {
        self.modifier(LoadingModifier(isLoading: isLoading, background: background, textColor: textColor, width: width, height: height, action: action))
    }
}

struct DynamicLoader: View {
    
    @State private var isLoading:Bool = false
    @State public var color:Color = .black
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            Circle()
                .trim(from: .zero,to: 0.6)
                .stroke(LinearGradient(colors: [color, color.opacity(0.0)], startPoint: .leading, endPoint: .trailing),style: StrokeStyle(lineWidth: 4,lineCap: .round))
                .frame(width: 33,height: 33)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut) {
                isLoading = true
            }
        }
    }
}



#Preview {
    ZStack{
        Rectangle()
            .foregroundColor(.gray)
        StyledButton(label: "Button", background: .white, textColor: .black) {
            print("tapped")
        }
    }
}
