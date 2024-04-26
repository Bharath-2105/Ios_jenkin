
import SwiftUI
import UIKit

enum FancyToastStyle: String {
    case error = "Error"
    case warning = "Warning"
    case success = "Success"
    case info = "Info"
}

extension FancyToastStyle {
    var themeColor: Color {
        switch self {
        case .error: return Color.red
        case .warning: return Color.orange
        case .info: return Color.blue
        case .success: return Color.green
        }
    }
    
    var iconFileName: String {
        switch self {
        case .info: return Images.infoIcon
        case .warning: return Images.warningIcon
        case .success: return Images.checkmarkIcon
        case .error: return Images.errorIcon
        }
    }
}

struct FancyToast: Equatable {
    var type: FancyToastStyle
    var title: String
    var message: String
    var duration: Double = 3
}

struct FancyToastView: View {
    var type: FancyToastStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: type.iconFileName)
                    .foregroundColor(type.themeColor)
                
                VStack(alignment: .leading) {
                    CustomText.InterSemiBoldText(title, fontSize: .subHeadingMedium, color: .black)
                    CustomText.InterRegularText(message, fontSize: .body, color: Color.black.opacity(0.6))
                }
                
                Spacer(minLength: 10)
                
                Button {
                    onCancelTapped()
                } label: {
                    Image(systemName: Images.xmark)
                        .foregroundColor(Color.black)
                }
            }
            .padding()
        }
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(type.themeColor)
                .frame(width: 6)
                .clipped()
            , alignment: .leading
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}

struct FancyToastModifier: ViewModifier {
    @Binding var toast: FancyToast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: -30)
                }.animation(.spring(), value: toast)
            )
            .onChange(of: toast) { value in
                showToast()
            }
    }
    
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer()
                FancyToastView(
                    type: toast.type,
                    title: toast.title,
                    message: toast.message) {
                        dismissToast()
                    }
            }
            .transition(.move(edge: .bottom))
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
               dismissToast()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func toastView(toast: Binding<FancyToast?>) -> some View {
        self.modifier(FancyToastModifier(toast: toast))
    }
}

#Preview {
    FancyToastView(
               type: .info,
               title: "Info",
               message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ") {}
}

protocol FancyToastDelegate: AnyObject {
    func closeButtonTapped(for toast: FancyToastUIView)
}

class FancyToastUIView: UIView {
    
    let type: FancyToastStyle
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    let cancelButton = UIButton(type: .system)
    var onCancelTapped: (() -> Void)?
    weak var delegate: FancyToastDelegate?
    
    init(type: FancyToastStyle, title: String, message: String, onCancelTapped: (() -> Void)?) {
        self.type = type
        self.onCancelTapped = onCancelTapped
        super.init(frame: CGRect.zero)
        
        backgroundColor = UIColor.white
        layer.cornerRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 1)
        
        let iconImageView = UIImageView(image: UIImage(systemName: type.iconFileName))
        iconImageView.tintColor = UIColor(type.themeColor)
        
        titleLabel.text = title
        titleLabel.font = UIFont(name: Fonts.interBold, size: 14)
        titleLabel.textColor = UIColor.black
        
        messageLabel.text = message
        messageLabel.font = UIFont(name: Fonts.interRegular, size: 12)
        messageLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        messageLabel.numberOfLines = 0
        
        cancelButton.setImage(UIImage(systemName: Images.xmark), for: .normal)
        cancelButton.tintColor = UIColor.black
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(cancelButton)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            cancelButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 17),
            cancelButton.heightAnchor.constraint(equalToConstant: 17)
        ])
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor(type.themeColor)
        overlayView.frame = CGRect(x: 0, y: 0, width: 6, height: bounds.height)
        addSubview(overlayView)
        bringSubviewToFront(overlayView)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 8, height: 8)).cgPath
        layer.mask = maskLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError(Messages.initCoderError)
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.closeButtonTapped(for: self)
        onCancelTapped?()
    }
}

extension UIView: FancyToastDelegate {
    
    func closeButtonTapped(for toast: FancyToastUIView) {
        toast.removeFromSuperview()
    }
    
    func showToast(toast: FancyToast) {
        let toastView = FancyToastUIView(
            type: toast.type,
            title: toast.title,
            message: toast.message,
            onCancelTapped: {
            }
        )
        addSubview(toastView)
        toastView.delegate = self
        toastView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastView.centerXAnchor.constraint(equalTo: centerXAnchor),
            toastView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32),
            toastView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            toastView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        if toast.duration > 0 {
            UIView.animate(withDuration: 0.5, delay: toast.duration, options: .curveEaseOut, animations: {
                toastView.alpha = 0.0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
}
