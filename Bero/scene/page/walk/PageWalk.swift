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
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var snsManager:SnsManager
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
                    SelectControlBox(
                        pageObservable: self.pageObservable,
                        viewModel: self.mapModel
                    )
                    Spacer().modifier(MatchParent())
                    if !self.isWalk {
                        StartBox()
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                    } else {
                        WalkBox(
                            pageObservable: self.pageObservable,
                            viewModel: self.mapModel,
                            isFollowMe: self.$isFollowMe
                        )
                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                    }
                }
                .padding(.bottom, Dimen.app.bottom + Dimen.margin.thin)
                .modifier(PageVertical())
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
        .onAppear{
            self.isFollowMe = Self.isFollowMe
            self.walkManager.startMap()
            
        }
        .onDisappear{
            Self.isFollowMe = self.isFollowMe
            self.walkManager.endMap()
        }
    }//body
    @State var isInit:Bool = false
    @State var isWalk:Bool = false
}


#if DEBUG
struct PageWalk_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWalk().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

