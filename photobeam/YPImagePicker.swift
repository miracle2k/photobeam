//
//  YPImagePicker.swift
//  photobeam
//
//  Created by Michael on 9/8/20.
//

import SwiftUI
import YPImagePicker

struct YPImagePickerView: UIViewControllerRepresentable
{
    func makeUIViewController(context: Context) -> YPImagePicker {
        let vc =  YPImagePicker()
        vc.didFinishPicking { [unowned vc] items, _ in
            if let photo = items.singlePhoto {
                print(photo.fromCamera) // Image source (camera or library)
                print(photo.image) // Final image selected by the user
                print(photo.originalImage) // original image selected by the user, unfiltered
                print(photo.modifiedImage) // Transformed image, can be nil
                print(photo.exifMeta) // Print exif meta data of original image.
            }
            vc.dismiss(animated: true, completion: nil)
        }
        print("\nmakeUIViewController \(vc)")
        return vc
    }

    func updateUIViewController(_ uiViewController: YPImagePicker, context: Context) {
        print("updateUIViewController \(uiViewController)")
    }

    static func dismantleUIViewController(_ uiViewController: YPImagePicker, coordinator: Self.Coordinator) {
        print("dismantleUIViewController \(uiViewController)")
    }

}
