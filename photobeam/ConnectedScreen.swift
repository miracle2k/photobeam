//
//  ConnectedView.swift
//  photobeam
//
//  Created by Michael on 8/5/20.
//

import SwiftUI

struct ConnectedScreen: AppScreen {
    var backgroundColor: Color = Color.blue;
    @EnvironmentObject var dataStore: DataStore;
    @State private var showingActionSheet = false
    @State private var presented = false

    var body: some View {
        VStack {
            HStack() {
                Spacer();
                Button("More") { showingActionSheet = true; }.actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Account"), buttons: [
                        .default(Text("Disconnect")) {
                            handleDisconnectClick()
                        },
                        .cancel()
                    ])
                }
            }.padding()
            Spacer()
            ZStack {
                DoubleImageView()
                if dataStore.isUploading {
                    ProgressView()
                }
            }
            Spacer()
            Text("Photo").modifier(RoundButton(action: {
                self.presented.toggle()
            })).fullScreenCover(isPresented: $presented) {
//                YPBasedImagePicker { (image) in
//                    self.handlePhotoPicked(image: image)
//                }
                StandardImagePicker { (image) in
                    self.handlePhotoPicked(image: image)
                }
            }
        }
    }
    
    func handleDisconnectClick() {
        self.dataStore.disconnect();
    }
    
    func handleSendPhoto() {
        //self.showYPImagePickerView.toggle()
    }
    
    func handlePhotoPicked(image: UIImage) {
        self.dataStore.setImage(image: image)
        
    }
}


struct DoubleImageView: View {
    @EnvironmentObject var dataStore: DataStore;
    @State private var isShowingSent = false
    
    var body: some View {
        var image = isShowingSent ? self.dataStore.sentImage : self.dataStore.receivedImage;
        var content: AnyView;
        
        if (image == nil) {
            content = AnyView(Text("Does not exist").onTapGesture {
                self.isShowingSent.toggle()
            })
        }
        else {
            content = AnyView(Image(uiImage: image!)
                .resizable()
                .scaledToFit()
                .cornerRadius(35.5)
                .padding()
                .onTapGesture {
                    self.isShowingSent.toggle()
                })
        }
        
        return Group {
            content
        }
        
    }
}


struct ConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedScreen()
    }
}
