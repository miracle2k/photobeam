//
//  NotConnectedScreen.swift
//  photobeam
//
//  Created by Michael on 8/5/20.
//

import SwiftUI
import Moya
import PromiseKit

struct NotConnectedScreen: View {
    @State private var text: String = ""
    @State private var isLoading = false
    @EnvironmentObject var dataStore: DataStore;
    

    var body: some View {
        VStack {
            Text("You are not connected to anyone.")
            Text("Code for others to connect to you: " + (dataStore.state.account?.connectCode ?? ""))
            TextField("Foobar", text: $text).multilineTextAlignment(TextAlignment.center).autocapitalization(.none)
            if isLoading {
                ProgressView()
            }
            Button(action: handleButtonClick) {
                Text("Connect!")
            }
        }
    };
    
    func handleButtonClick() {
        self.isLoading = true;
        let waitAtLeast = after(seconds: 0.5)
        dataStore.connect(code: self.text).then { waitAtLeast }.ensure {
            self.isLoading = false;
        }
    }
}

struct NotConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        NotConnectedScreen()
    }
}
