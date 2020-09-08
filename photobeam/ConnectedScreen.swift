//
//  ConnectedView.swift
//  photobeam
//
//  Created by Michael on 8/5/20.
//

import SwiftUI

struct ConnectedScreen: View {
    @EnvironmentObject var dataStore: DataStore;
    @State private var presented = false

    var body: some View {
        VStack {
            Text("Connected")
            Button("Set New Photo") {
                self.presented.toggle()
            }.fullScreenCover(isPresented: $presented) {
                StandardImagePicker { (image) in
                    self.handlePhotoPicked(image: image)
                }
            }
            
            Button(action: handleDisconnectClick) {
                Text("Disconnect")
            }
        }
    }
    
    func handleDisconnectClick() {
        
    }
    
    func handleSendPhoto() {
        //self.showYPImagePickerView.toggle()
    }
    
    func handlePhotoPicked(image: UIImage) {
        self.dataStore.setImage(image: image);
        
    }
}


struct ConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedScreen()
    }
}