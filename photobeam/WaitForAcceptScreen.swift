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
    
    var body: some View {
        VStack {
            Text("Waiting for Accept")
            Button(action: {
                self.dataStore.disconnect();
            }) {
                Text("Disconnect")
            }.buttonStyle(FilledButton())
        }
    }
}

struct WaitForAcceptScreen_Previews: PreviewProvider {
    static var previews: some View {
        WaitForAcceptScreen()
    }
}
