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
                    if self.isWalk {
                        WalkBox(
                            pageObservable: self.pageObservable,
                            viewModel: self.mapModel,
                            isFollowMe: self.$isFollowMe
                        )
                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                    }
                    Spacer().modifier(MatchParent())
                    if self.isInitable {
                        if !self.isWalk {
                            StartBox(
                                pageObservable: self.pageObservable,
                                viewModel: self.mapModel,
                                isFollowMe: self.$isFollowMe
                            )
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                        } 
                    }
                }
                .padding(.bottom, Dimen.app.bottom + Dimen.margin.thin)
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
        .onReceive(self.walkManager.$status){ status in
            switch status {
            case .ready :
                self.isWalk = false
            case .walking :
                self.isWalk = true
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
        .onReceive(self.dataProvider.user.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .addedDog, .deletedDog, .updatedDogs:
                withAnimation{
                    self.isInitable = !self.dataProvider.user.pets.isEmpty
                }
                self.needDog()
            
            default : break
            }
        }
        .onReceive(self.mapModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .tabMarker(let marker) : self.onMapMarkerSelect(marker)
            case .tabOffMarker(let marker) : self.onMapMarkerDisSelect(marker)
            case .move(let isUser) :
                if isUser {
                    self.isFollowMe = false
                }
            }
        }
        .onAppear{
            
            self.walkManager.startMap()
            withAnimation{
                self.isInitable = !self.dataProvider.user.pets.isEmpty
            }
            
            
        }
        .onDisappear{
            self.walkManager.endMap()
        }
    }//body
    @State var isInitable:Bool = false
    @State var isInit:Bool = false
    @State var isWalk:Bool = false
   
    private func needDog(){
        if !self.dataProvider.user.pets.isEmpty { return }
        self.appSceneObserver.sheet = .select(
            String.alert.addDogTitle,
            String.alert.addDogText,
            image:Asset.image.addDog,
            [String.button.later,String.button.ok]){ idx in
                if idx == 1 {
                    self.pagePresenter.openPopup(PageProvider.getPageObject(.addDog))
                }
        }
    }
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

