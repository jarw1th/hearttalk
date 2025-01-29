//
//  PhotosPickerView.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 29.01.2025.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPickerView

        init(parent: PhotoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            if let result = results.first {
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    if let image = object as? UIImage, error == nil {
                        DispatchQueue.main.async {
                            HapticManager.shared.triggerHapticFeedback(.light)
                            SoundManager.shared.sound(.click1)
                            self.parent.selectedImage.wrappedValue = image
                        }
                    }
                }
            } else {
                // Handle the case where the user cancels without picking anything
                DispatchQueue.main.async {
                    self.parent.selectedImage.wrappedValue = nil
                }
            }
        }
    }

    var selectedImage: Binding<UIImage?>
    var configuration: PHPickerConfiguration

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let vc = PHPickerViewController(configuration: configuration)
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
