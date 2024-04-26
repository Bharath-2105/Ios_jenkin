import SwiftUI
import Combine

struct OtpFormFieldView: View {
    
    @FocusState private var pinFocusState: FocusPin?
    @FocusState var focusPinOne: Bool
    @State var pinOne: String = ""
    @State var pinTwo: String = ""
    @State var pinThree: String = ""
    @State var pinFour: String = ""
    @State var lineWidth: CGFloat = 3
    @State var pinOneBorderColor: Color = Colors.adaptiveColor
    @State var pinTwoBorderColor: Color = .gray
    @State var pinThreeBorderColor: Color = .gray
    @State var pinFourBorderColor: Color = .gray
    @Binding var otpValue: String
    @Binding var showWrongOtpInputView: Bool
    @Binding var focusState: FocusPin?
    var otpFont: Font = CustomText.InterBlackFont.headingLarge.fontBold
    var body: some View {
        HStack(spacing: 40, content: {
            StyledTextField(text: $pinOne, bgBorderColor: $pinOneBorderColor, LineWidth: focusState == .pinOne ? 3 : lineWidth, font: otpFont, keyboardType: .numberPad, alignment: .center)
                .modifier(OtpModifer(pin: $pinOne))
                .onTapGesture {
                    otpfieldTappedAction(pin: .pinOne)
                }
                .onChange(of: pinOne){ newVal in
                    if showWrongOtpInputView && !newVal.isEmpty {
                        withAnimation {
                            showWrongOtpInputView = false
                        }
                        changeBorderColor()
                    } else {
                        focusState = .pinTwo
                    }
                    pinOne = getPinValue(newValue: newVal, currentPinNumber: .pinOne, nextPinNumber: .pinTwo)
                    otpValue = pinOne + pinTwo + pinThree + pinFour
                }
                .focused($focusPinOne)
                .focused($pinFocusState, equals: .pinOne)
            
            StyledTextField(text: $pinTwo, bgBorderColor: $pinTwoBorderColor, LineWidth:  focusState == .pinTwo ? 3 : lineWidth, font: otpFont, keyboardType: .numberPad, alignment: .center)
                .modifier(OtpModifer(pin: $pinTwo))
                .onTapGesture {
                    otpfieldTappedAction(pin: .pinTwo)
                    changeBorderColor()
                }
                .onChange(of: pinTwo){ newVal in
                    if showWrongOtpInputView && !newVal.isEmpty {
                        showWrongOtpInputView = false
                    }
                    focusState = .pinThree
                    pinTwo = getPinValue(newValue: newVal, currentPinNumber: .pinTwo, nextPinNumber: .pinThree)
                    otpValue = pinOne + pinTwo + pinThree + pinFour
                }
                .focused($pinFocusState, equals: .pinTwo)
            
            StyledTextField(text: $pinThree, bgBorderColor: $pinThreeBorderColor, LineWidth:  focusState == .pinThree ? 3 : lineWidth, font: otpFont, keyboardType: .numberPad, alignment: .center)
                .modifier(OtpModifer(pin: $pinThree))
                .onTapGesture {
                    otpfieldTappedAction(pin: .pinThree)
                }
                .onChange(of: pinThree){ newVal in
                    if showWrongOtpInputView && !newVal.isEmpty {
                        showWrongOtpInputView = false
                    }
                    focusState = .pinFour
                    pinThree = getPinValue(newValue: newVal, currentPinNumber: .pinThree, nextPinNumber: .pinFour)
                    otpValue = pinOne + pinTwo + pinThree + pinFour
                }
                .focused($pinFocusState, equals: .pinThree)
            
            StyledTextField(text: $pinFour, bgBorderColor: $pinFourBorderColor, LineWidth:  focusState == .pinFour ? 3 : lineWidth, font: otpFont, keyboardType: .numberPad, alignment: .center)
                .modifier(OtpModifer(pin: $pinFour))
                .onChange(of: pinFour){ newVal in
                    if showWrongOtpInputView && !newVal.isEmpty {
                        showWrongOtpInputView = false
                    }
                    focusState = .pinFour
                    pinFour = getPinValue(newValue: newVal, currentPinNumber: .pinFour, nextPinNumber: .pinFour)
                    otpValue = pinOne + pinTwo + pinThree + pinFour
                }
                .onTapGesture {
                    otpfieldTappedAction(pin: .pinFour)
                }
                .focused($pinFocusState, equals: .pinFour)
        })
        .onChange(of: showWrongOtpInputView){ newVal in
            if newVal {
                pinOne = ""
                pinTwo = ""
                pinThree = ""
                pinFour = ""
            }
        }
        .onChange(of: focusState){ newVal in
            changeBorderColor()
        }
        .onAppear {
            focusPinOne = true
        }.onDisappear {
            focusPinOne = false
        }
    }
    private func changeBorderColor() {
        if showWrongOtpInputView {
            pinOneBorderColor = .red
            pinTwoBorderColor = .red
            pinThreeBorderColor = .red
            pinFourBorderColor = .red
            lineWidth = 3
        } else {
            lineWidth = 3
            pinOneBorderColor = (focusState == .pinOne) ? Colors.adaptiveColor : .gray
            pinTwoBorderColor = (focusState == .pinTwo) ? Colors.adaptiveColor : .gray
            pinThreeBorderColor = (focusState == .pinThree) ? Colors.adaptiveColor : .gray
            pinFourBorderColor = (focusState == .pinFour) ? Colors.adaptiveColor : .gray
        }
    }
    private func otpfieldTappedAction(pin: FocusPin) {
        withAnimation{
            showWrongOtpInputView = false
        }
        focusState = pin
    }
    private func getPinValue(newValue: String, currentPinNumber: FocusPin, nextPinNumber: FocusPin) -> String {
        var focusPin: FocusPin?
        var pinValue: String = newValue
        if newValue.count == 0 {
            focusPin = currentPinNumber
        } else if let lastValue = newValue.last {
            pinValue = "\(lastValue)"
            focusPin = nextPinNumber
        }
        pinFocusState = focusPin
        return pinValue
    }
}
