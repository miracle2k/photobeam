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
            Text("You have a request, do you want to accept?")
            Button(action: {
                self.dataStore.respondToConnectionRequest(shouldAccept: true);
            }) {
                Text("yes")
            }.buttonStyle(FilledButton())
            Button(action: {
                self.dataStore.respondToConnectionRequest(shouldAccept: false);
            }) {
                Text("no")
            }.buttonStyle(FilledButton())
        }
    }
}

struct ConfirmRequestScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmRequestScreen()
    }
}
