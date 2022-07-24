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

struct PageTestMap: PageView {
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
            
            self.appSceneObserver.radio = .sort(
                ("key",
                 ["test1", "test2", "test3", "test4", "test5", "test6", "test7", "test8", "test9", "test10"]),
                title: "title", description: "description"){ select in
                
            }
             
        }
        
    
    }//body
    
    func onPageReload() {
        PageLog.log("PAGE  VIEW EVENT")
    }
    
}


#if DEBUG
struct PageTestMap_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageTestMap().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

