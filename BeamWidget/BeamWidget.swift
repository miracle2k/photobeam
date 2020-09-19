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
     * How do we keep the widget up to date? I struggled with this a lot, due to lack of experience with the platform (and lack of docs from Apple).
     *
     * 1) On Silent Push Notifications.
     *
     *  I only note: It seems those are not called on a regular basis, or only with some delay.
     *
     * 2) In regular intervals, in case the push notification is missed.
     *
     * For those second part,  I see two options:
     *
     * 1) Use the "background update task" feature which allows our app to be called in certain intervals. This is mentioned in the docs:
     *   https://developer.apple.com/documentation/widgetkit/timelineprovider
     *   But the background fetch is also limited if the app is not opened often, could this be a problem for us? Also see the discussion here:
     *   https://developer.apple.com/forums/thread/659373
     *
     *   This approach also has the advantage that it runs once for the whole app, not for every single widget.
     *
     * 2) Using the getTimeline() function. Apple seems to use this approach in their WWDC video:
     *   https://developer.apple.com/videos/play/wwdc2020/10036
     *   But we have to work around the fact it will be called multiple times for multiple widgets - a possible workaround is described here:
     *   https://developer.apple.com/forums/thread/659319
     *   It is also not clear to me how this interacts with background downloads, i.e. if we first have to start the bg download, we return an empty
     *   timeline, then update via the WidgetCenter.updateAll() method? (the docs seem to suggest this)
     *
     * In all cases: It is not always clear how much time we have, and whether it would be preferable or necessary to start a background download
     * task instead. My guess is that we should do so, for *all* download cases.
     *
     * So depending on the approach chosen above, we have to either return policy=never (and rely on a bg  update task)
     * We return "refresh now", with policy=never. We then manually send a refresh request whenever we get a new picture, which itself
     * is refreshed via a background task & push notification.    
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
