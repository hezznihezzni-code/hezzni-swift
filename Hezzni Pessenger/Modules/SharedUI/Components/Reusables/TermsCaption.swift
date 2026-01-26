import SwiftUI

struct TermsCaption: View {
    @State private var tappedTerms = false
    @State private var tappedPrivacy = false
    
    var body: some View {
        Text(attributedString)
            .font(.caption)
            .foregroundColor(.gray)
            .environment(\.openURL, OpenURLAction { url in
                handleLinkTap(url.absoluteString)
                return .handled
            })
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    private var attributedString: AttributedString {
        var terms = AttributedString("Terms of Service")
        terms.link = URL(string: "terms")
        terms.foregroundColor = tappedTerms ? .green.opacity(0.7) : .green
        
        var privacy = AttributedString("Privacy Policy")
        privacy.link = URL(string: "privacy")
        privacy.foregroundColor = tappedPrivacy ? .green.opacity(0.7) : .green
        
        var base = AttributedString("By continuing, you agree to our ")
        base.foregroundColor = .gray
        
        var and = AttributedString(" and ")
        and.foregroundColor = .gray
        
        return base + terms + and + privacy
    }
    
    private func handleLinkTap(_ urlString: String) {
        if urlString == "terms" {
            withAnimation(.easeInOut(duration: 0.1)) {
                tappedTerms = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    tappedTerms = false
                }
            }
            print("Terms of Service tapped")
        } else if urlString == "privacy" {
            withAnimation(.easeInOut(duration: 0.1)) {
                tappedPrivacy = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    tappedPrivacy = false
                }
            }
            print("Privacy Policy tapped")
        }
    }
}
