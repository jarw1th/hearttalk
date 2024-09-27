
import SwiftUI
import YandexMobileAds

struct BannerAdView: UIViewRepresentable {
    
    let adUnitID: String
    
    func makeUIView(context: Context) -> AdView {
        let adSize = BannerAdSize.stickySize(withContainerWidth: UIScreen.main.bounds.width)
        let bannerView = AdView(adUnitID: adUnitID, adSize: adSize)
        bannerView.delegate = context.coordinator
        bannerView.loadAd()
        return bannerView
    }

    func updateUIView(_ uiView: AdView, context: Context) {
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, AdViewDelegate {
        func bannerViewDidLoad(_ bannerView: AdView) {
            print("Banner loaded successfully")
        }

        func bannerView(_ bannerView: AdView, didFailLoadingWithError error: Error) {
            print("Failed to load banner: \(error.localizedDescription)")
        }
    }
    
}
