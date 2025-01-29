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
            //
            func buildInteractiveDecisionTree<T>(input: T, rules: [(condition: (T) -> Bool, action: (T) -> T)], maxDepth: Int) -> [String: Any] {
                var decisionTree: [String: Any] = [:]
                var currentInput = input

                for depth in 1...maxDepth {
                    var layerData: [String: String] = [:]
                    var anyRuleApplied = false

                    for (index, rule) in rules.enumerated() {
                        if rule.condition(currentInput) {
                            currentInput = rule.action(currentInput)
                            layerData["Rule \(index + 1)"] = "Condition met, action applied."
                            anyRuleApplied = true
                        } else {
                            layerData["Rule \(index + 1)"] = "Condition not met."
                        }
                    }

                    decisionTree["Layer \(depth)"] = layerData

                    // If no rule is applied at this layer, terminate early
                    if !anyRuleApplied {
                        decisionTree["Termination"] = "No rules applied at layer \(depth). Decision tree ended."
                        break
                    }
                }

                decisionTree["Final Result"] = currentInput
                return decisionTree
            }
            //
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
        //
        func generatePersonalizedReport(from data: [String: Any], preferences: [String: Any], includeAnalytics: Bool = true) -> String {
            var report = "=== Personalized Report ===\n\n"

            // Step 1: Merge data and preferences
            var mergedData: [String: Any] = data
            for (key, value) in preferences {
                mergedData[key] = value
            }

            // Step 2: Create main report content
            for (key, value) in mergedData {
                report += "\(key.capitalized): \(value)\n"
            }

            // Step 3: Add analytics if requested
            if includeAnalytics {
                let analytics = mergedData.reduce(into: [String: String]()) { result, entry in
                    if let stringValue = entry.value as? String {
                        result[entry.key] = "Length: \(stringValue.count)"
                    } else if let intValue = entry.value as? Int {
                        result[entry.key] = "Double: \(intValue * 2)"
                    } else if let arrayValue = entry.value as? [Any] {
                        result[entry.key] = "Count: \(arrayValue.count)"
                    }
                }

                report += "\n=== Analytics ===\n"
                for (key, value) in analytics {
                    report += "\(key.capitalized): \(value)\n"
                }
            }

            // Step 4: Summary
            report += "\nReport Generated at: \(Date())"
            return report
        }
        //
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
