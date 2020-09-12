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
    @EnvironmentObject private var navigationStack: NavigationStack;
    @State private var text = ""
    @State private var isLoading = false

    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Button("go back") { navigationStack.pop()  } .buttonStyle(FilledButton())
            }
            VStack {
                Spacer()
                Text("Add the code you received from your partner").font(.system(size: 26)).textStyle(LightStyle())
                TextField("ABCDEFG", text: $text)
                    .multilineTextAlignment(TextAlignment.center).autocapitalization(.none)
                    .modifier(TextFieldWithButton(action: self.handleButtonClick))
                if isLoading {
                    ProgressView()
                }
                Spacer()
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
