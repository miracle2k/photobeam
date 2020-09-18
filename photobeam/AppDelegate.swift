//
//  AppDelegate.swift
//  photobeam
//
//  Created by Michael on 6/24/20.
//

import UIKit
import BackgroundTasks


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // This registers the handler for our task - when the system runs our task, it will run this handler.
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.photobeam.refresh",
            using: DispatchQueue.global()
        ) { task in
            self.handleImageFetch(task: task as! BGAppRefreshTask)
        }
        
        return true
    }
    
    /**
     * The handler function for our background refresh task.
     */
    private func handleImageFetch(task: BGAppRefreshTask) {
        // This is called when are out of time. We might cancel our active requests.
        task.expirationHandler = {
            
        }
        
        //task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))

        // Schedule another one.
        scheduleBackgroundRefresh()
    }
    
    func scheduleBackgroundRefresh() {
        let task = BGAppRefreshTaskRequest(identifier: "com.photobeam.refresh")
        task.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        do {
          try BGTaskScheduler.shared.submit(task)
        } catch {
          print("Unable to submit task: \(error.localizedDescription)")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: PushNotification callbacks
    
    // Callback from OS when we successfully register for push notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        print("Received apns device token callback - success")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        ApnsDeviceTokenState.shared.deviceToken = token;
    }
    
    // Callback from OS when registering for push notifications fails.
    func application(_ application: UIApplication,
                didFailToRegisterForRemoteNotificationsWithError
                    error: Error) {
       // Try again later.
        print("Received apns device token callback - failure")
        ApnsDeviceTokenState.shared.deviceToken = "error";
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received push notification")
        // Is there a better way to access the data store?
        SceneDelegate.sharedDataStore?.refreshState().done {
            completionHandler(.newData)
        }
    }
}

