//
//  NotConnectedScreen.swift
//  photobeam
//
//  Created by Michael on 8/5/20.
//

import SwiftUI
import Moya
import PromiseKit

protocol AppScreen: View {
    var backgroundColor: Color { get }
}

struct NotConnectedScreen: AppScreen {
    
    @EnvironmentObject var dataStore: DataStore;
    @EnvironmentObject private var navigationStack: NavigationStack
    
    var backgroundColor: Color = Color(#colorLiteral(red: 0.4000000059604645, green: 0.18039216101169586, blue: 0.6078431606292725, alpha: 1));
    

    
    var body: some View {
        VStack {
            Spacer()
            Text("Your Code").font(.custom("Roboto Light", size: 30)).foregroundColor(Color(#colorLiteral(red: 1, green: 0.94, blue: 0.99, alpha: 1))).multilineTextAlignment(.center).padding(.bottom, 40)
            Text((dataStore.state.account?.connectCode ?? "")).font(.custom("Roboto Bold", size: 40)).foregroundColor(Color(#colorLiteral(red: 1, green: 0.94, blue: 0.99, alpha: 1))).multilineTextAlignment(.center)
            Spacer()
            Button("Connect to someone") { goToNextClick() }.buttonStyle(FilledButton())
            Spacer()
        }.frame(minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
        )
    };
    
    func goToNextClick() {
        DispatchQueue.main.async {
            self.navigationStack.push(ConnectScreen())
        }
    }
}

struct NotConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        NotConnectedScreen()
    }
}
