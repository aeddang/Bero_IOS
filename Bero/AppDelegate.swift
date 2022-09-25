//
//  AppDelegate.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/01.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GooglePlaces
import GoogleMaps
import FBSDKCoreKit
import GoogleSignIn

class AppObserver: ObservableObject, PageProtocol {
    @Published fileprivate(set) var page:IwillGo? = nil
    @Published fileprivate(set) var pushToken:String? = nil
    @Published private(set) var apns:[AnyHashable: Any]? = nil
    
    func resetToken(){
        pushToken = nil
    }

    func reset(){
        page = nil
    }
    func resetApns(){
        apns = nil
    }
    let gcmMessageIDKey = "gcm.message_id"
    let pageKey = "page"
    let apnsKey = "aps"

    func handleApns(_ userInfo: [AnyHashable: Any]){
        if let messageID = userInfo[gcmMessageIDKey] {
             PageLog.d("Message ID: \(messageID)", tag: self.tag)
        }
        if let jsonString = userInfo[pageKey] as? String {
            PageLog.d("pageJson : \(jsonString)" , tag: self.tag)
            self.page = WhereverYouCanGo.parseIwillGo(jsonString: jsonString)
        }
        if let aps = userInfo[apnsKey] as? [String: Any] {
            PageLog.d("aps: \(aps.debugDescription)" , tag: self.tag)
            self.apns = userInfo
        }
        
        
    }
    
    @discardableResult
    func handleUniversalLink(_ deepLink: URL?)-> Bool{
        guard let url =  deepLink else { return false }
        return DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
            if let query = dynamiclink?.url?.query{
                PageLog.d("Deeplink dynamiclink : \(query)", tag: self.tag)
                self.page = WhereverYouCanGo.parseIwillGo(qurryString: query)
            }else{
                PageLog.d("Deeplink dynamiclink : no query", tag: self.tag)
            }
        }
    }
    
    @discardableResult
    func handleDynamicLink(_ deepLink: URL?)-> Bool{
        guard let url =  deepLink else { return false }
        if let dynamiclink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            if let query = dynamiclink.url?.query{
                PageLog.d("Deeplink dynamiclink : \(query)", tag: self.tag)
                self.page = WhereverYouCanGo.parseIwillGo(qurryString: query)
            }else{
                PageLog.d("Deeplink dynamiclink : no query", tag: self.tag)
            }
             return true
        }else{
            return false
        }
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PageProtocol {
    static var orientationLock = UIInterfaceOrientationMask.all
    static let appObserver = AppObserver()
    static private(set) var appURLSession:URLSession? = nil
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        GMSPlacesClient.provideAPIKey("AIzaSyCHDB1mFuj7MEaCwxBSzCLqXGSGtWJ97fA")
        GMSServices.provideAPIKey("AIzaSyCHDB1mFuj7MEaCwxBSzCLqXGSGtWJ97fA")
        DynamicLinks.performDiagnostics(completion: nil)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        Self.appURLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        let launchedURL = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL
        
        //[FB]
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        //[Google]
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
              // Show the app's signed-out state.
            } else {
              // Show the app's signed-in state.
            }
        }
        return AppDelegate.appObserver.handleDynamicLink(launchedURL)
    }
    

    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        //[FB]
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        //[Google]
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        
        //[DL]
        let dynamicLink = application(app, open: url,
                     sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                     annotation: "")
        
        return dynamicLink
        
    }
    
    // [Deeplink]
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        PageLog.d("Deeplink start", tag: self.tag)
        return AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        PageLog.d("Deeplink start", tag: self.tag)
        return AppDelegate.appObserver.handleDynamicLink(url)
    }
    
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config  = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        //config.delegateClass = SceneDelegate.self
        return config
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    
    
    
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        AppDelegate.appObserver.handleApns(userInfo)
        PageLog.d("didReceiveRemoteNotification", tag: self.tag)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppDelegate.appObserver.handleApns(userInfo)
        PageLog.d("didReceiveRemoteNotification fetchCompletionHandler", tag: self.tag)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PageLog.d("Unable to register for remote notifications: \(error.localizedDescription)", tag: self.tag)
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PageLog.d("APNs token retrieved: \(deviceToken.base64EncodedString())", tag: self.tag)
       // AppDelegate.appObserver.pushToken = deviceToken.base64EncodedString()
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
          if let error = error {
            PageLog.e("Error fetching FCM registration token: \(error)", tag: self.tag)
          } else if let token = token {
            PageLog.d("Firebase registration token: \(token)", tag: self.tag)
            AppDelegate.appObserver.pushToken = token
          }
        }
    }

}

extension AppDelegate : URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
           let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, urlCredential)
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        AppDelegate.appObserver.handleApns(userInfo)
        PageLog.d("userNotificationCenter []", tag: self.tag)
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        AppDelegate.appObserver.handleApns(userInfo)
        PageLog.d("userNotificationCenter {}", tag: self.tag)
        completionHandler()
    }
}



extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        PageLog.d("Firebase registration token: \(token)", tag: self.tag)
        let dataDict:[String: String] = ["token": token ]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        AppDelegate.appObserver.pushToken = token
    }
}

