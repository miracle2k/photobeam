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
    public func snapshot(with context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
}

struct SimpleEntry: TimelineEntry {
    public let date: Date
}

struct PlaceholderView : View {
    var body: some View {
        Text("Placeholder View")
    }
}

struct WidgetEntryView : View {
    var entry: Provider.Entry
//    var loader: ImageLoader;
//
//    init() {
//        loader = ImageLoader(url: "https://images.unsplash.com/photo-1592945843838-c69fc7dacb08?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3300&q=80");
//    }

    let destinationFileUrl = getDocumentsDirectory().appendingPathComponent("output.jpg")
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(contentsOfFile: destinationFileUrl.path)!)
                .resizable()
                .scaledToFit()
        }
    }
}

@main
struct BeamWidget: SwiftUI.Widget {
    private let kind: String = "com.photobeam.widget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}


func getDocumentsDirectory() -> URL {
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.elsdoerfer.photobeam")!;
    
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    do {
        let items = try FileManager.default.contentsOfDirectory(at: paths[0].absoluteURL, includingPropertiesForKeys: nil, options: [])

        for item in items {
            print("Found \(item)")
        }
    } catch {
        // failed to read directory – bad permissions, perhaps?
    }
    
    print(paths[0])
    return paths[0]
}
