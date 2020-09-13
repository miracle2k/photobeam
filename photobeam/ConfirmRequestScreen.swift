//
//  ConfirmRequestScreen.swift
//  photobeam
//
//  Created by Michael on 9/9/20.
//

import SwiftUI

struct ConfirmRequestScreen: View {
    var backgroundColor: Color = Color.green;
    @EnvironmentObject var dataStore: DataStore;
    
    var body: some View {
        VStack {
            Text("You have an incoming connection request.\nDo you accept?").textStyle(LightStyle()).font(.system(size: 30))
            HStack {
                Button(action: {
                    self.dataStore.respondToConnectionRequest(shouldAccept: true);
                }) {
                    Text("Accept")
                }.buttonStyle(FilledButton(color: MyColors.yellow))
                Button(action: {
                    self.dataStore.respondToConnectionRequest(shouldAccept: false);
                }) {
                    Text("Cancel")
                }.buttonStyle(FilledButton(color: MyColors.yellow))
            }.padding(.top, 15)
        }
    }
}

struct ConfirmRequestScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmRequestScreen()
    }
}
