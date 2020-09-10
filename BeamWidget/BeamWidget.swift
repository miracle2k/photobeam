//
//  Widget.swift
//  Widget
//
//  Created by Michael on 6/24/20.
//

import WidgetKit
import SwiftUI
import Intents


struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (ShowFrameEntry) -> Void) {
        let entry = ShowFrameEntry(date: Date(), isEmpty: true)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ShowFrameEntry>) -> Void) {
        let entry = ShowFrameEntry(date: Date(), isEmpty: true)
        let entries: [ShowFrameEntry] = [entry]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
        
    func placeholder(in context: Context) -> ShowFrameEntry {
        ShowFrameEntry(date: Date(), isEmpty: true)
    }
}

struct ShowFrameEntry: TimelineEntry {
    public let date: Date
    public let isEmpty: Bool
}

struct FrameView : View {
    var entry: ShowFrameEntry;

    let destinationFileUrl = getDocumentsDirectory().appendingPathComponent("output.jpg")
    
    var body: some View {
        switch entry.isEmpty {
        case false:
            VStack {
                Image(uiImage: UIImage(contentsOfFile: destinationFileUrl.path)!)
                    .resizable()
                    .scaledToFit()
            }
        case true:
            VStack {
                Text("Not Connected").bold().padding(.bottom, 5)
                Text("Launch the app to connect to your partner.").font(.system(size: 14)).multilineTextAlignment(.center)
            }.padding(10)
        }
        
    }
}

@main
struct BeamWidget: SwiftUI.Widget {
    private let kind: String = "com.photobeam.widget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FrameView(entry: entry)
        }
        .configurationDisplayName("PhotoBeam")
        .description("This is the photo beam widget")
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}


func getDocumentsDirectory() -> URL {
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.elsdoerfer.photobeam")!;
}
