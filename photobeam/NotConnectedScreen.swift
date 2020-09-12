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
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Spacer()
                Text("Your Code").bold().textStyle(LightStyle()).padding(.bottom, 1).font(.system(size: 18))
                Text((dataStore.state.account?.connectCode ?? "")).bold().font(.system(size: 50)).textStyle(LightStyle())
                Text("Give this code to your partner to allow them to connect with you.")
                    .font(.system(size: 16)).textStyle(LightStyle()).padding(.top, 20)
                Spacer()
            }
            VStack(alignment: .leading) {
                Spacer()
                Button("Enter Connection Code") { goToNextClick() }.buttonStyle(FilledButton())
                Text("Or, if you have received a connection code from someone, tap here to enter it.")
                    .font(.system(size: 16)).textStyle(LightStyle()).padding(.top, 10)
                Spacer()
            }
        }
        .padding()
        .frame(minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity,
                alignment: .topLeading
        )
    };
    
    func goToNextClick() {
        DispatchQueue.main.async {
            self.navigationStack.push(ScreenDefinition(
                id: "connect",
                backgroundColor: MyColors.pink,
                righthandColor: MyColors.yellow,
                screen: AnyView(ConnectScreen())
            ))
        }
    }
}

struct NotConnectedScreen_Previews: PreviewProvider {
    static var previews: some View {
        NotConnectedScreen()
    }
}
