
import SwiftUI

struct TextView: UIViewRepresentable {
    
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = UIColor.clear
        textView.textAlignment = NSTextAlignment.center
        textView.font = UIFont(name: "PlayfairDisplay-SemiBold", size: UIDevice.current.userInterfaceIdiom == .phone ? 20 : 32)
        textView.textColor = UIColor(.lightBlack)
        textView.autocapitalizationType = .sentences
        textView.autocorrectionType = .no
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        
        DispatchQueue.main.async {
            let fittingSize = uiView.sizeThatFits(CGSize(width: uiView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            let verticalPadding = max(0, (uiView.frame.height - fittingSize.height) / 2)
            uiView.contentInset.top = verticalPadding
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
    
}
