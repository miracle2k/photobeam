////
////  CrashDeckLogger.swift
////  photobeam
////
////  Created by Michael on 9/19/20.
////
//
//import Foundation
//#if canImport(FoundationNetworking)
//import FoundationNetworking
//#endif
import Logging
import SwiftyBeaver
import Foundation


public struct BeaverLogHandler: LogHandler {
    public var metadata = Logger.Metadata()
    public var logLevel = Logger.Level.info
    
    let userDefaultsGroup = UserDefaults(suiteName: "group.com.elsdoerfer.photobeam")!
    
    init() {
        var appId = UUID().uuidString;
        let lowerBound = String.Index(encodedOffset: 1)
        let upperBound = String.Index(encodedOffset: 4)
        appId = String(appId[lowerBound..<upperBound])
        
        if (userDefaultsGroup.string(forKey: "appId") == nil) {
            userDefaultsGroup.set(appId, forKey: "appId")
        }
    
        let platform = SBPlatformDestination(appID: "zLgAQp", appSecret: "ejgeQpenxyugmCi2aOwtyzSjkIQfnrBg", encryptionKey: "4v9p74eG4kpFotlruryo2DVvpwpkGkze")
        platform.sendingPoints.threshold = 1
        SwiftyBeaver.addDestination(platform)
    }
    
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            metadata[metadataKey]
        }
        set(newValue) {
            metadata[metadataKey] = newValue
        }
    }
    
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        let appId = userDefaultsGroup.string(forKey: "appId")!
        SwiftyBeaver.info(appId + ": " + message.description)
    }

    
}

//  http https://api.crashdeck.io/log-5f6624387c6ad0359b317e46 message=foo type=error channel=""  Authorization:V0XPrgdzDYHXj9qYEvg56Dc75jcbP1B9dEvY
