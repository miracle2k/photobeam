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
    @State private var showError = false

    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Button(action: { navigationStack.pop() }) {
                    Image("back-arrow").foregroundColor(MyColors.yellow).frame(width: 28, height: 28)
                }
            }
            VStack(alignment: .leading) {
                Spacer()
                Text("Add the code you received from your partner.").font(.system(size: 26)).textStyle(LightStyle()).padding(.bottom, 10)
                TextField("ABCDEFG", text: $text)
                    .multilineTextAlignment(TextAlignment.center).autocapitalization(.none)
                    .modifier(TextFieldWithButton(action: self.handleButtonClick, isLoading: isLoading))
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: .infinity)
            .alert(isPresented: $showError) {
                Alert(title: Text("The connection code you entered is not valid. Please try again."))
            }
        }
        .padding()
        .frame(minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
        )
    }
    
    func handleButtonClick() {
        self.isLoading = true;
        let waitAtLeast = after(seconds: 0.5)
        dataStore.connect(code: self.text).then { waitAtLeast }.ensure {
            self.isLoading = false;
        }.catch({ err in
            self.showError = true;
        })
    }
}

struct ConnectScreen_Previews: PreviewProvider {
    static var previews: some View {
        ConnectScreen()
    }
}
