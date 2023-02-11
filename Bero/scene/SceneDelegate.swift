//
//  SceneDelegate.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/01.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import UIKit
import SwiftUI
import FBSDKCoreKit
import Firebase

class SceneDelegate: PageSceneDelegate {
    var repository:Repository? = nil
    override func onInitController(controller: PageContentController) {
        controller.pageControllerObservable.overlayView = AppLayout()
    }
    override func onInitPage() {
        
    }
    override func getPageModel() -> PageModel { return PageSceneModel()}
    override func adjustEnvironmentObjects<T>(_ view: T) -> AnyView where T : View
    {
        
        let sceneObserver = AppSceneObserver()
        let dataProvider = DataProvider()
        let networkObserver = NetworkObserver()
        let snsManager = SnsManager()
        let keyboardObserver = KeyboardObserver()
        let locationObserver = LocationObserver()
        let walkManager = WalkManager(
            appSceneObserver: sceneObserver, 
            dataProvider: dataProvider, 
            locationObserver:locationObserver
        )
        self.pagePresenter.bodyColor = Color.brand.bg
        let res = Repository(
            dataProvider: dataProvider,
            networkObserver: networkObserver,
            pagePresenter: self.pagePresenter,
            sceneObserver: sceneObserver,
            snsManager: snsManager,
            locationObserver: locationObserver,
            walkManager:walkManager
        )
        self.repository = res
        
        let environmentView = view
            .environmentObject(AppDelegate.appObserver)
            .environmentObject(res)
            .environmentObject(dataProvider)
            .environmentObject(networkObserver)
            .environmentObject(sceneObserver)
            .environmentObject(keyboardObserver)
            .environmentObject(locationObserver)
            .environmentObject(snsManager)
            .environmentObject(walkManager)
            
        return AnyView(environmentView)
    }
    override func willChangeAblePage(_ page: PageObject?, isCloseAllPopup: Bool = false) -> Bool {
        return true
    }
    override func getPageContentProtocol(_ page: PageObject, pageObservable:PageObservable) -> PageViewProtocol {
        return PageFactory.getPage(page, pageObservable:pageObservable)
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        PageLog.d("Deeplink openURLContexts", tag: self.tag)
        guard let url = URLContexts.first?.url else { return }
        
        //[DL]
        AppDelegate.appObserver.handleDynamicLink(url)
        
        //[FB]
        if let url = URLContexts.first?.url {
            ApplicationDelegate.shared.application(
               UIApplication.shared,
               open: url,
               sourceApplication: nil,
               annotation: [UIApplication.OpenURLOptionsKey.annotation]
            )
        }
    }
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        PageLog.d("Deeplink willConnectTo", tag: self.tag)
        //AppDelegate.appObserver.handleDynamicLink(connectionOptions.urlContexts.first?.url)
        //AppDelegate.appObserver.handleUniversalLink(connectionOptions.userActivities.first?.webpageURL)
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    /*
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        PageLog.d("Deeplink continue userActivity", tag: self.tag)
        AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    */
    
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        PageLog.d("Deeplink didUpdate userActivity", tag: self.tag)
        //AppDelegate.appObserver.handleUniversalLink(userActivity.webpageURL)
    }
    
    override func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    
}
