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
    @State private var activePage: String = "";

    var body: some View {
        VStack {
            HStack() {
                Spacer();
                Button(action: { showingActionSheet = true }) {
                    HStack {
                        Image("triangle")
                            .rotationEffect(.degrees(-90))
                            .foregroundColor(MyColors.yellow)
                            .frame(width: 16, height: 16)
                        Text("More").textStyle(DarkStyle())
                    }
                }.actionSheet(isPresented: $showingActionSheet) {
                    ActionSheet(title: Text("Account"), buttons: [
                        .destructive(Text("Disconnect")) {
                            handleDisconnectClick()
                        },
                        .cancel()
                    ])
                }
            }.padding()
            Spacer()
            ZStack {
                DoubleImageView(page: self.$activePage).padding()
                if dataStore.isUploading {
                    ProgressView()
                }
            }
            Spacer()
            HStack {
                Image("camera").resizable().padding(5).frame(width: 40, height: 40).modifier(RoundButton(action: {
                    self.presented.toggle()
                }, color: MyColors.yellow)).fullScreenCover(isPresented: $presented) {
                    YPBasedImagePicker { (image) in
                        self.handlePhotoPicked(image: image)
                    }
//                    StandardImagePicker { (image) in
//                        self.handlePhotoPicked(image: image)
//                    }
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
        self.activePage = "sent"
        self.dataStore.setImage(image: image)
        
    }
}


struct DoubleImageView: View {
    @EnvironmentObject var dataStore: DataStore;
    
    @Binding var page: String;
        
    var pages: [String] = [
        "received", "sent"
    ]
    
    var body: some View {
        var pageIndex = Binding<Int>(
            get: {
                return pages.index(of: $page.wrappedValue) ?? 0
            },
            set: { s in
                page = pages[s]
            }
        )
        
        return Pager(
            page: pageIndex,
            data: pages,
            id: \.self,
            content: self.getPage).contentLoadingPolicy(.eager).itemSpacing(10)
            .rotation3D()
    }
    
    func getPage(index: String) -> some View {
        // create a page based on the data passed
        var image = index == "sent" ? self.dataStore.sentImage : self.dataStore.receivedImage;
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

