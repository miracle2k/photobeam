//
//  WaitForAcceptScreen.swift
//  photobeam
//
//  Created by Michael on 9/9/20.
//

import SwiftUI

struct WaitForAcceptScreen: AppScreen {
    var backgroundColor: Color = Color.green;
    @EnvironmentObject var dataStore: DataStore;
    @State var play: Bool = true;
    
    var body: some View {
        VStack {
            LottieView(name: "connecting", play: $play)
                            .frame(width: 150, height: 150)
            Text("Waiting for Accept").font(.system(size: 30))
            Button(action: {
                self.dataStore.disconnect();
            }) {
                Text("Cancel")
            }.buttonStyle(FilledButton(color: nil)).padding(.top, 50)
        }
    }
}

struct WaitForAcceptScreen_Previews: PreviewProvider {
    static var previews: some View {
        WaitForAcceptScreen()
    }
}
