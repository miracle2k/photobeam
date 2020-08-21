//
//  NotConnectedScreen.swift
//  photobeam
//
//  Created by Michael on 8/5/20.
//

import SwiftUI
import Moya

struct NotConnectedScreen: View {
    @State private var connectCode: String = "f34ds34"
    @State private var text: String = ""
    @State private var showingAlert = false
    @EnvironmentObject var dataStore: DataStore;
    

    var body: some View {
        VStack {
            Text("You are not connected to anyone.")
            Text("Code for others to connect to you: " + connectCode)
            TextField("Foobar", text: $text).multilineTextAlignment(TextAlignment.center)
            Button(action: handleButtonClick) {
                Text("Connect!")
            }.alert(isPresented: $showingAlert) {
                Alert(title: Text("Important message"), message: Text("Wear sunscreen"), dismissButton: .default(Text("Got it!")))
            }
            dataStore.state.account.map {_ in
                Text("Current State" + String(dataStore.state.account!.accountId))
            }
        }
    };
    
    func handleButtonClick() {
        // handle any exception, show an alert
        dataStore.ensureAccount();
        dataStore.connect(code: self.text)
    }
}

struct NotConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        NotConnectedScreen()
    }
}
