//
//  ConnectedView.swift
//  photobeam
//
//  Created by Michael on 8/5/20.
//

import SwiftUI
import SwiftUIPager

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
                DoubleImageView().padding()
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
    @State var page: Int = 0
    
    var pages: [String] = [
        "received", "sent"
    ]
    
    var body: some View {
        return Pager(
            page: $page,
            data: pages,
            id: \.self,
            content: self.getPage).contentLoadingPolicy(.eager).itemSpacing(10)
            .rotation3D()
    }
    
    func getPage(index: String) -> some View {
        // create a page based on the data passed
        var image = index == "received" ? self.dataStore.sentImage : self.dataStore.receivedImage;
        var content: AnyView;
        
        if (image == nil) {
            content = AnyView(Text("Does not exist").onTapGesture {
                
            })
        }
        else {
            content = AnyView(Image(uiImage: image!)
                .resizable()
                .scaledToFit().background(Color.blue)
                                // For some reason, without the padding, cornerRadius only works on same images???
                                .padding(1)
                                .cornerRadius(35)
            )
        }
        
        return Group { content }
    }
}


struct ConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectedScreen()
    }
}
