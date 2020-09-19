//
//  Widget.swift
//  Widget
//
//  Created by Michael on 6/24/20.
//

import WidgetKit
import SwiftUI
import Intents
import Logging


struct Provider: TimelineProvider {
    private let urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "MySession")
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config)
    }();
    
    func getSnapshot(in context: Context, completion: @escaping (ShowFrameEntry) -> Void) {
        logger.info("BeamWidget:getSnapshot()")
        // We must return the snapshot quickly, so we either return the current image, or a dummy.
        let exists = FileManager.default.fileExists(atPath: Paths.receivedUrl.path);
        let entry = ShowFrameEntry(date: Date(), isEmpty: !exists)
        completion(entry)
    }
    
    /**
     * We return "refresh now", with policy=never. We then manually send a refresh request whenever we get a new picture, which itself
     * is refreshed via a background task & push notification.
     *
     * We could try to use a Widget refresh policy (every hour?) for this, but iOS limits that (no idea to what frequency), and in general they
     * do recommend a background fetch task:
     * https://developer.apple.com/documentation/widgetkit/timelineprovider
     * But the background fetch is also limited if the app is not opened often, could this be a problem for us? Also see the discussion here:
     * https://developer.apple.com/forums/thread/659373
     *
     * However, I suppose we could try to set a policy to every couple of hours here as well, but that only makes sense if we also try to *fetch* here.
     *
     *
     * ---
     *
     * Actually, do the query.
     */
    func getTimeline(in context: Context, completion: @escaping (Timeline<ShowFrameEntry>) -> Void) {
        logger.info("BeamWidget:getTimeline()")
        // possibly do a query()
        // then try to download the file right now
        // later worry about the bg mode.
        
        let store = DataStore(setupTimer: false, loadImages: false)
        store.refreshState().done {
            let exists = FileManager.default.fileExists(atPath: Paths.receivedUrl.path);
            let entry = ShowFrameEntry(date: Date(), isEmpty: !exists)
            let entries: [ShowFrameEntry] = [entry]
            let timeline = Timeline(entries: entries, policy: .after(
                Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
            ))
            completion(timeline)
        }.catch { err in
            print("Error occured:", err)
            
        }
        
        // Relevant links:
        // https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date (section "Update After Background Network Requests Complete")
//        let downloadTask = URLSession.shared.downloadTask(with: URL(string: "https://picsum.photos/400")!) { (url, response, error) in
//            print("download complete")
//            guard let fileURL = url else { return }
//            do {
//                _ = try FileManager.default.replaceItemAt(Paths.receivedUrl, withItemAt: fileURL)
//            } catch {
//                print ("file error: \(error)")
//            }
//
//            let entry = ShowFrameEntry(date: Date(), isEmpty: false)
//            let entries: [ShowFrameEntry] = [entry]
//            let timeline = Timeline(entries: entries, policy: .after(
//                Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
//            ))
//            completion(timeline)
//        }
//        downloadTask.resume();
        
//        let exists = FileManager.default.fileExists(atPath: Paths.receivedUrl.path);
//        let entry = ShowFrameEntry(date: Date(), isEmpty: !exists)
//        let entries: [ShowFrameEntry] = [entry]
//        let timeline = Timeline(entries: entries, policy: .never)
//        completion(timeline)
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
    
    var body: some View {
        switch entry.isEmpty {
        case false:
            VStack {
                Image(uiImage: UIImage(contentsOfFile: Paths.receivedUrl.path)!)
                    .resizable()
                    .scaledToFill()
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
    
    init() {
        LoggingSystem.bootstrap { label in
            MultiplexLogHandler([
                BeaverLogHandler(),

                // Setup the standard logging backend to enable console logging
                StreamLogHandler.standardOutput(label: label),
            ])
        }
        logger.info("BeamWidget main() called.")
    }

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
