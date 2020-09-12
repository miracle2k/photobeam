//
//  ContentView.swift
//  photobeam
//
//  Created by Michael on 6/24/20.
//

import SwiftUI
import UIKit

struct MyColors {
    static var purple = Color(#colorLiteral(red: 0.4000000059604645, green: 0.18039216101169586, blue: 0.6078431606292725, alpha: 1));
    static var pink = Color(#colorLiteral(red: 1, green: 0.2862745225429535, blue: 0.6196078658103943, alpha: 1))
    static var yellow = Color(#colorLiteral(red: 0.9764705896377563, green: 0.7843137383460999, blue: 0.054901961237192154, alpha: 1))
    static var blue = Color(#colorLiteral(red: 0.26274511218070984, green: 0.7372549176216125, blue: 0.8039215803146362, alpha: 1));
}

struct ContentView: View {

    @ObservedObject private var dataStore: DataStore;
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore;
        self.dataStore.ensureAccount()
    }
    
    func getRootView() -> ScreenDefinition {
        if (self.dataStore.state.connection?.peerId ?? 0) != 0 {
            if (self.dataStore.state.connection?.status == "connected") {
                return ScreenDefinition(
                    backgroundColor: MyColors.blue,
                    righthandColor: MyColors.blue,
                    screen: AnyView(ConnectedScreen())
                )
            }
            else if (self.dataStore.state.connection?.status == "pendingWithMe") {
                return ScreenDefinition(
                    backgroundColor: MyColors.yellow,
                    righthandColor: MyColors.blue,
                    screen: AnyView(ConfirmRequestScreen())
                )
            }
            else {
                return ScreenDefinition(
                    backgroundColor: MyColors.yellow,
                    righthandColor: MyColors.blue,
                    screen: AnyView(WaitForAcceptScreen())
                )
            }
        } else {
            return ScreenDefinition(
                backgroundColor: MyColors.purple,
                righthandColor: MyColors.pink,
                screen: AnyView(ConnectScreen())
            )
        }
    }
    
    var body: some View {
        NavigationStackView(rootView: self.getRootView())
    }
    
    func refresh() {
        dataStore.refreshState();
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dataStore: DataStore())
    }
}


func getDocumentsDirectory() -> URL {
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.elsdoerfer.photobeam")!;
}
