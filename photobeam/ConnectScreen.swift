//
//  ConnectScreen.swift
//  photobeam
//
//  Created by Michael on 9/9/20.
//

import SwiftUI
import PromiseKit

struct ConnectScreen: AppScreen {
    var backgroundColor: Color = Color.green;
    @EnvironmentObject var dataStore: DataStore;
    @State private var text = ""
    @State private var isLoading = false

    
    var body: some View {
        VStack {
            Text("Connection Code:")
                .font(.custom("Roboto Medium", size: 20)).foregroundColor(Color(#colorLiteral(red: 0.28, green: 0.26, blue: 0.26, alpha: 1))).multilineTextAlignment(.center)
            TextField("type something...", text: $text)
                .textFieldStyle(SuperCustomTextFieldStyle())
                .multilineTextAlignment(TextAlignment.center).autocapitalization(.none)
            Button(action: handleButtonClick) { Text("Connect") }.buttonStyle(FilledButton())
            if isLoading {
                ProgressView()
            }
        }.padding()
    }
    
    func handleButtonClick() {
        self.isLoading = true;
        let waitAtLeast = after(seconds: 0.5)
        dataStore.connect(code: self.text).then { waitAtLeast }.ensure {
            self.isLoading = false;
        }
    }
}

struct ConnectScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectScreen()
    }
}

struct SuperCustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding()
            .border(Color.accentColor)
    }
}
