//
//  PhotoPicker.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 06.02.2025.
//

import SwiftUI
import PhotosUI

struct PhotoPickerRepresentable: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedImage: $selectedImage)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        @Binding var selectedImage: UIImage?
        
        init(selectedImage: Binding<UIImage?>) {
            _selectedImage = selectedImage
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            if let result = results.first {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                    DispatchQueue.main.async {
                        if let image = object as? UIImage {
                            self?.selectedImage = image
                        }
                    }
                }
            }
        }
    }
    
}
