//
//  PageTest.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine

extension PageWalk{
    static private var isFollowMe:Bool = false
}

struct PageWalk: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var mapModel:PlayMapModel = PlayMapModel()
   
    @State var isFollowMe:Bool = false
    @State var isForceMove:Bool = false
   
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center)
            {
                PlayMap(
                    pageObservable: self.pageObservable,
                    viewModel: self.mapModel,
                    isFollowMe: self.$isFollowMe,
                    isForceMove: self.$isForceMove,
                    bottomMargin: self.appSceneObserver.safeBottomHeight
                )
                .modifier(MatchParent())
                
                VStack(alignment: .trailing, spacing: Dimen.margin.thin){
                    WalkBox(
                        pageObservable: self.pageObservable,
                        viewModel: self.mapModel
                    )
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    
                    Spacer().modifier(MatchParent())
                    
                    PlayBox(
                        pageObservable: self.pageObservable,
                        viewModel: self.mapModel,
                        isFollowMe: self.$isFollowMe
                    )
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                }
                .padding(.bottom, self.bottomMargin + Dimen.margin.thin )
                .modifier(PageVertical())
                PlayEffect(
                    pageObservable: self.pageObservable,
                    viewModel: self.mapModel,
                    isFollowMe: self.$isFollowMe
                )
                .modifier(MatchParent())
                
            }
            .modifier(MatchParent())
            .background(Color.brand.bg)
            
        }//GeometryReader
        .onReceive(self.walkManager.$currentLocation){ loc in
            guard let loc = loc else {return}
            if !self.isInit {
                self.isInit = true
                self.walkManager.updateMapStatus(loc)
            }
        }
        .onReceive(self.walkManager.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .closeAllPopup : self.closeAllPopup()
            default : break
            }
        }
        .onReceive(self.walkManager.$error){ err in
            guard let err = err else {return}
            switch err {
            case .accessDenied :
                self.appSceneObserver.alert = .alert(nil, String.alert.needLocationAccess){
                    guard let settingURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingURL) else { return }
                    UIApplication.shared.open(settingURL, options: [:])
                }
            default : break
            }
            
        }
        .onReceive(self.walkManager.$status){ status in
            switch status {
            case .ready :
                self.isWalk = false
            case .walking :
                self.isWalk = true

            }
        }
        .onReceive(self.appSceneObserver.$useBottom){ useBottom in
            withAnimation{
                self.bottomMargin = useBottom ? Dimen.app.bottom : 0
            }
            
        }
        .onReceive(self.walkManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .findPlace(let place) :
                if self.pagePresenter.hasPopup(find: .popupWalkPlace) {return}
                self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkPlace).addParam(key: .data, value: place))
            default : break
            }
        }
    
        .onReceive(self.mapModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .tab(_) : self.closeAllPopup()
            case .tabMarker(let marker) : self.onMapMarkerSelect(marker)
            case .tabOffMarker(let marker) : self.onMapMarkerDisSelect(marker)
            case .move(let isUser) :
                if isUser {
                    self.isFollowMe = false
                }
            }
        }
        .onAppear{
            self.bottomMargin = self.appSceneObserver.useBottom ? Dimen.app.bottom : 0
            self.walkManager.startMap()
            if !self.repository.storage.isFirstWalk {
                self.repository.storage.isFirstWalk = true
                self.walkManager.firstWalk()
                
            } 
        }
        .onDisappear{
            self.walkManager.endMap()
        }
    }//body
    @State var isInitable:Bool = false
    @State var isInit:Bool = false
    @State var isWalk:Bool = false
    @State var bottomMargin:CGFloat = 0
    
   
}


#if DEBUG
struct PageWalk_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWalk().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

