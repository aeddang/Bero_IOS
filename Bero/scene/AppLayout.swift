//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct AppLayout: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var keyboardObserver:KeyboardObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @State var loadingInfo:[String]? = nil
    @State var isLoading = false
    @State var isInit = false
  
    
    var body: some View {
        ZStack{
            SceneTab()
            SceneRadioController()
            SceneSelectController()
            ScenePickerController()
            SceneAlertController()
            SceneSheetController()
            if self.isLoading {
                Spacer().modifier(MatchParent()).background(Color.transparent.black70)
                if self.loadingInfo != nil {
                    VStack(spacing:0){
                        ForEach(self.loadingInfo!, id: \.self ) { text in
                            Text( text )
                                .modifier(MediumTextStyle( size: Font.size.medium, color:Color.app.white ))
                        }
                        Spacer().modifier(MatchParent())
                    }
                    .padding(.horizontal, Dimen.margin.regular)
                    .frame(height: 300)
                    
                }
                ActivityIndicator(isAnimating: self.$isLoading, style: .large)
            }
        }
        .onReceive(self.pagePresenter.$isLoading){ loading in
            DispatchQueue.main.async {
                withAnimation{
                    self.isLoading = loading
                }
            }
        }
        .onReceive(self.appSceneObserver.$loadingInfo){ loadingInfo in
            self.loadingInfo = loadingInfo
            withAnimation{
                self.isLoading = loadingInfo == nil ? false : true
            }
        }
        .onReceive(self.appSceneObserver.$event){ evt in
            guard let evt = evt else { return }
            switch evt  {
            case .initate: self.onPageInit()
            default: break
            }
        }
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            guard let cPage = page else { return }
            PageLog.d("currentTopPage " + cPage.pageID.debugDescription, tag:self.tag)
            
            self.appSceneObserver.useBottom = PageSceneModel.needBottomTab(cPage)
            AppUtil.hideKeyboard()
            if PageSceneModel.needKeyboard(cPage) {
                self.keyboardObserver.start()
            }else{
                self.keyboardObserver.cancel()
            }
            self.updateSafeArea()
        }
        .onReceive (self.sceneObserver.$isUpdated) { _ in
            self.updateSafeArea()
        }
        
        .onReceive (self.appObserver.$page) { iwg in
            if !self.isInit { return }
            self.appObserverMove(iwg)
        }
        .onReceive (self.appObserver.$apns) { apns in
            if apns == nil {return}
            if !self.isInit { return }
            self.appSceneObserver.alert = .recivedApns
        }
        .onReceive (self.appObserver.$pushToken) { token in
            guard let token = token else { return }
            self.repository.registerPushToken(token)
        }
        
        .onReceive(self.repository.$status){ status in
            switch status {
            case .ready: self.onStoreInit()
            default: break
            }
        }
        .onReceive(self.repository.$event){ evt in
            switch evt {
            case .loginUpdate: self.onPageInit()
            default: break
            }
        }
        .onReceive(self.pageObservable.$status){status in
            self.sceneObserver.status = status
        }
        .onAppear(){
            self.isLoading = true
            //UITableView.appearance().separatorStyle = .none
            /*
            for family in UIFont.familyNames.sorted() {
                let names = UIFont.fontNames(forFamilyName: family)
                PageLog.d("Family: \(family) Font names: \(names)")
            }
            */
        }
    }
    func onStoreInit(){
        //self.appSceneObserver.event = .debug("onStoreInit")
        if SystemEnvironment.firstLaunch {
            self.pagePresenter.changePage(
                PageProvider.getPageObject(.intro)
            )
            return
        }
        self.onPageInit()
    }
    func onPageInit(){
        self.isLoading = false
        PageLog.d("onPageInit", tag: self.tag)
        
        if !self.repository.isLogin {
            self.isInit = false
            if self.pagePresenter.currentPage?.pageID != .login {
                self.pagePresenter.changePage(
                    PageProvider.getPageObject(.login)
                )
            }
            return
        }
        
        self.isInit = true
        if !self.appObserverMove(self.appObserver.page) {
            self.pagePresenter.changePage(
                PageProvider.getPageObject(.walk)
            )
        }
        if self.appObserver.apns != nil  {
            self.appSceneObserver.event = .debug("apns exist")
            self.appSceneObserver.alert = .recivedApns
        } else {
            self.appSceneObserver.sheet = .select(
                String.alert.addDogTitle,
                String.alert.addDogText,
                Asset.image.addDog,
                [String.button.later,String.button.ok]){ idx in
                    if idx == 1 {
                        self.pagePresenter.openPopup(PageProvider.getPageObject(.addDog))
                    }
            }
        }
    }
    
    func onPageReset(){
        self.appSceneObserver.event = .debug("onPageReset")
        self.pagePresenter.changePage(
            PageProvider.getPageObject(.walk)
        )
    }
    
    func onPageError(_ err:ApiResultError?){
        /*
        self.pagePresenter.changePage(
            PageProvider.getPageObject(.serviceError)
        )
        */
    }
    
    @discardableResult
    func appObserverMove(_ iwg:IwillGo? = nil) -> Bool {
        guard let page = iwg?.page else { return false }
        if PageProvider.isHome(page.pageID) { page.isPopup = false }
        if page.isPopup {
            self.pagePresenter.openPopup(page)
        }else{
            self.pagePresenter.changePage(page)
        }
        self.appObserver.reset()
        return !page.isPopup
    }
    
    private func updateSafeArea(){
        var bottom = self.appSceneObserver.useBottom ? Dimen.app.bottom : 0
        self.appSceneObserver.safeBottomHeight = bottom + self.sceneObserver.safeAreaBottom
        self.appSceneObserver.safeHeaderHeight = self.sceneObserver.safeAreaTop
    }
    
}


