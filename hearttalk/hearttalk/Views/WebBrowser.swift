//
//  WebBrowser.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 30.01.2025.
//

import SwiftUI
import WebKit

struct WebBrowser: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var link: String
    @State private var canGoBack: Bool = false
    @State private var canGoForward: Bool = false
    @State private var webView: WKWebView = WKWebView()
    
    var body: some View {
        makeContent()
            .background(.lightBlack)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    private func makeContent() -> some View {
        VStack(spacing: 40) {
            WebBrowserTopBar(text: Localization.browser, canGoBack: canGoBack, canGoForward: canGoForward) {
                link = ""
                dismiss()
            } backTapAction: {
                if webView.canGoBack {
                    webView.goBack()
                }
            } forwardTapAction: {
                if webView.canGoForward {
                    webView.goForward()
                }
            }
            .padding(.vertical, 16)
            
            WebView(urlString: $link, canGoBack: $canGoBack, canGoForward: $canGoForward, webView: $webView)
                .cornerRadius(12)
            
            makeCreateButton()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 70 : 120)
    }
    
    @ViewBuilder
    private func makeCreateButton() -> some View {
        Button {
            dismiss()
        } label: {
            Text(Localization.attach)
                .font(.custom("Poppins-Regular", size: UIDevice.current.userInterfaceIdiom == .phone ? 16 : 32))
                .underline()
                .multilineTextAlignment(.center)
                .foregroundStyle(.darkWhite)
        }
    }
    
}
