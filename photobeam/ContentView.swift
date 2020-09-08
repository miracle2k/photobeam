//
//  ContentView.swift
//  photobeam
//
//  Created by Michael on 6/24/20.
//

import SwiftUI
import UIKit

struct ContentView: View {

    private var dataStore: DataStore;
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore;
        self.dataStore.ensureAccount()
    }
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: 20) {
            VStack() {
                if !self.dataStore.isInitialized {
                    Text("still loading...")
                }
                else if self.dataStore.state.connection != nil {
                   ConnectedScreen()
                } else {
                   NotConnectedScreen()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)        
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
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.elsdoerfer.photobeam")!;
//    print(paths[0])
//    return paths[0]
}
