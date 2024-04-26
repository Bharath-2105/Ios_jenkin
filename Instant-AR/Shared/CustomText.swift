import Foundation
import SwiftUI
class CustomText {
    enum InterBlackFont: CGFloat {
        case Big = 110
       case subBig = 68
        case titleLarge = 55
        case titleMedium = 48
        case subTitleLarge = 40
        case subtitleMedium = 30
        case headingLarge = 25
        case headingSubLarge = 22
        case headingMedium = 18
        case subHeadingLarge = 16
        case subHeadingMedium = 14
        case body = 12
        case subBody = 10
        
        var fontBold: Font {
            return Font.custom(Fonts.interBlack, size: self.rawValue)
        }
    }
    struct InterBlackText: View {
        let text: String
        let fontType: InterBlackFont?
        let color: Color?
        
        init(_ text: String, fontSize: InterBlackFont? = .subBody, color: Color? = .black) {
            self.text = text
            self.fontType = fontSize
            self.color = color
        }
        
        var body: some View {
            Text(text)
                .font(fontType?.fontBold)
                .foregroundColor(color)
        }
    }
    
    enum InterBoldFont: CGFloat {
        case Big = 110
       case subBig = 68
        case titleLarge = 55
        case titleMedium = 48
        case subTitleLarge = 40
        case subtitleMedium = 30
        case headingLarge = 25
        case headingSubLarge = 22
        case headingMedium = 18
        case subHeadingLarge = 16
        case subHeadingMedium = 14
        case body = 12
        case subBody = 10
        
        var fontBold: Font {
            return Font.custom(Fonts.interBold, size: self.rawValue)
        }
    }
    struct InterBoldText: View {
        let text: String
        let fontType: InterBoldFont?
        let color: Color?
        
        init(_ text: String, fontSize: InterBoldFont? = .subBody, color: Color? = .black) {
            self.text = text
            self.fontType = fontSize
            self.color = color
        }
        
        var body: some View {
            Text(text)
                .font(fontType?.fontBold)
                .foregroundColor(color)
        }
    }
    
   enum InterRegularFont: CGFloat {
      case headingMedium = 18
      case subHeadingLarge = 16
      case subHeadingMedium = 14
      case body = 12
       
       var fontRegular: Font {
           return Font.custom(Fonts.interRegular, size: self.rawValue)
       }
   }
   struct InterRegularText: View {
       let text: String
       let fontType: InterRegularFont?
       let color: Color?
       
       init(_ text: String, fontSize: InterRegularFont? = .subHeadingMedium, color: Color? = .black) {
           self.text = text
           self.fontType = fontSize
           self.color = color
       }
       
       var body: some View {
           Text(text)
               .font(fontType?.fontRegular)
               .foregroundColor(color)
       }
   }
    enum InterSemiBoldFont: CGFloat {
       case headingMedium = 18
       case subHeadingLarge = 16
       case subHeadingMedium = 14
       case body = 12
        
        var fontRegular: Font {
            return Font.custom(Fonts.interSemiBold, size: self.rawValue)
        }
    }
    struct InterSemiBoldText: View {
        let text: String
        let fontType: InterSemiBoldFont?
        let color: Color?
        
        init(_ text: String, fontSize: InterSemiBoldFont? = .subHeadingMedium, color: Color? = .black) {
            self.text = text
            self.fontType = fontSize
            self.color = color
        }
        
        var body: some View {
            Text(text)
                .font(fontType?.fontRegular)
                .foregroundColor(color)
        }
    }

}
