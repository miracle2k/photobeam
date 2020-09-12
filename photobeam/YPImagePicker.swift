//
//  YPImagePicker.swift
//  photobeam
//
//  Created by Michael on 9/8/20.
//

import SwiftUI
import YPImagePicker

struct YPBasedImagePicker: UIViewControllerRepresentable
{
    @Environment(\.presentationMode) var presentationMode
    var imageSelected: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> YPImagePicker {
        let picker = YPImagePicker()
        picker.delegate = context.coordinator
        return picker    
    }

    func updateUIViewController(_ uiViewController: YPImagePicker, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, YPImagePickerDelegate {
        func noPhotos() {
        }
        
        func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
            return true;
        }
        
        let parent: YPBasedImagePicker

        init(_ parent: YPBasedImagePicker) {
            self.parent = parent
        }
        
        func imagePicker(_ imagePicker: YPImagePicker, didFinishPicking items: [YPMediaItem]) {
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

}
