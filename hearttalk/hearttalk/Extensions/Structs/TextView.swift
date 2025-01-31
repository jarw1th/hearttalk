//
//  TextView.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    
    @Binding var text: String
    var placeholder: String
    var placeholderColor: UIColor = UIColor.lightBlack.withAlphaComponent(0.5) 
    var textColor: UIColor = .lightBlack
    var backgroundColor: UIColor = .clear
    var font: UIFont? = UIFont(name: "Poppins-Regular", size: 16)
    var isScrollable: Bool = true

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = parent.textColor
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = parent.placeholderColor
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = backgroundColor
        textView.textColor = text.isEmpty ? placeholderColor : textColor
        textView.font = font ?? UIFont.systemFont(ofSize: 16)
        textView.text = text.isEmpty ? placeholder : text
        textView.isScrollEnabled = isScrollable
        textView.isEditable = true
        textView.isSelectable = true
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 8
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .sentences
        textView.contentInset = .zero
        textView.setContentOffset(.zero, animated: false)
        textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text.isEmpty ? placeholder : text
        }
        uiView.textColor = text.isEmpty ? placeholderColor : textColor
        
        if uiView.text == placeholder {
            uiView.textAlignment = .left
        } else {
            uiView.textAlignment = .natural
        }
    }
    
}
