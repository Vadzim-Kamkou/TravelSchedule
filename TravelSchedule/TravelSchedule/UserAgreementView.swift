import SwiftUI
import WebKit

struct UserAgreementView: View {
    
    private var agreementURL: URL? {
        guard let url = URL(string: "https://yandex.ru/legal/practicum_offer") else {
            return nil
        }
        return url
    }
    
    var body: some View {
        ZStack {
            Color("appWhite")
                .ignoresSafeArea()
            
            if let url = agreementURL {
                WebView(url: url)
            } else {
                VStack(spacing: 16) {
                    Text("error_page_unreachable")
                        .font(.system(size: 17))
                        .foregroundColor(Color("appBlack"))
                }
            }        }
        .navigationTitle("settings_useragreement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

#Preview {
    NavigationStack {
        UserAgreementView()
    }
}
