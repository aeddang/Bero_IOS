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

struct PageWalk: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var snsManager:SnsManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    
    @ObservedObject var mapModel:PlayMapModel = PlayMapModel()
   
    @State var isFollowMe:Bool = true
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
                    bottomMargin: 0
                )
                .modifier(MatchParent())
              
            }//VStack
            .modifier(MatchParent())
            .background(Color.app.white)
        }//GeometryReader
        .onAppear{
        
        }
    }//body
    
    func onPageReload() {
        PageLog.log("PAGE  VIEW EVENT")
    }
    
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

