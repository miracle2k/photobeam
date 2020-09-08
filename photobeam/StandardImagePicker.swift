//
//  StandardImagePicker.swift
//  photobeam
//
//  Created by Michael on 9/8/20.
//

import SwiftUI

struct StandardImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var imageSelected: (UIImage) -> Void

    func makeUIViewController(context: UIViewControllerRepresentableContext<StandardImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<StandardImagePicker>) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: StandardImagePicker

        init(_ parent: StandardImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                self.parent.imageSelected(uiImage);
                //parent.image = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
