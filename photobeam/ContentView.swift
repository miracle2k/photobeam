//
//  ContentView.swift
//  photobeam
//
//  Created by Michael on 6/24/20.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    init() {
        print("Ready")
    }
    
    var body: some View {
        Button(action: {
            let url = URL(string: "https://images.unsplash.com/photo-1592945843838-c69fc7dacb08?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3300&q=80");
            
            let destinationFileUrl = getDocumentsDirectory().appendingPathComponent("output.jpg")
            
            let session = URLSession(configuration: .default)

            // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
            let downloadPicTask = session.downloadTask(with: url!) { (tempLocalUrl, response, error) in
                // The download has finished.
                if let e = error {
                    print("Error downloading cat picture: \(e)")
                } else {
                    // No errors found.
                    // It would be weird if we didn't have a response, so check for that too.
                    if let res = response as? HTTPURLResponse {
                        print("Downloaded cat picture with response code \(res.statusCode)")
                                                
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl!, to: destinationFileUrl)
                        } catch (let writeError) {
                            print("Error creating a file \(destinationFileUrl) : \(writeError)")
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            };
            downloadPicTask.resume();
            
        }) {
            Text("Download Image2")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.elsdoerfer.photobeam")!;
//    print(paths[0])
//    return paths[0]
}
