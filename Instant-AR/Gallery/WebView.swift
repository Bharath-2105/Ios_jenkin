import SwiftUI
import WebKit

struct WebViewController: UIViewRepresentable {
    let link: String

    // Use Coordinator to manage WKNavigationDelegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator // Set the navigation delegate
        
        // Setup for activity indicator and label could be done here if needed
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: link){
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewController
        var activityIndicator: UIActivityIndicatorView?
        var loadingLabel: UILabel?

        init(_ webView: WebViewController) {
            self.parent = webView
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if activityIndicator == nil {
                activityIndicator = UIActivityIndicatorView(style: .large)
                webView.addSubview(activityIndicator!)
                activityIndicator?.center = webView.center
                activityIndicator?.startAnimating()
                activityIndicator?.color = .black
                
                loadingLabel = UILabel()
                webView.addSubview(loadingLabel!)
                loadingLabel?.text = Messages.loading
                loadingLabel?.center = CGPoint(x: webView.center.x, y: webView.center.y + 30)
            }

            activityIndicator?.isHidden = false
            loadingLabel?.isHidden = false
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            activityIndicator?.isHidden = true
            loadingLabel?.isHidden = true
        }
    }
}


