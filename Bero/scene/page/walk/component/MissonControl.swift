//
//  ComponentTabNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct MissionControl : PageComponent {
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    var data:Mission
    let close: (() -> Void)
    var body: some View {
        HStack(){
            VStack(alignment: .leading, spacing: 0){
                Spacer().modifier(MatchHorizontal(height: 0))
                if let text = self.data.title {
                    Text(text).modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.black))
                }
                if let text = self.data.description {
                    Text(text).modifier(RegularTextStyle(size: Font.size.light, color: Color.app.grey400))
                }
                if let text = self.data.place?.name {
                    Text(text).modifier(MediumTextStyle(size: Font.size.light, color: Color.brand.primary))
                }
            }
            if !self.isCompleted {
                CircleButton(
                    type: .icon(self.isPlay ? Asset.icon.pause : Asset.icon.play_circle_filled ),
                    isSelected: self.isPlay){ _ in
                        if self.walkManager.status != .walking {
                            self.appSceneObserver.alert = .confirm(nil, "산책시작후 미션수행이 가능합니다 산책을 시작하겠습니까?"){ isOk in
                                if isOk {
                                    self.walkManager.startWalk()
                                    self.startMission()
                                }
                            }
                            return
                        }
                        if self.isPlay {
                            self.appSceneObserver.alert = .confirm(nil, "미션을 종료 하겠습니까?"){ isOk in
                                if isOk {
                                    self.walkManager.endMission()
                                }
                            }
                            return
                        }
                        if self.walkManager.currentMission != nil {
                            self.appSceneObserver.event = .toast("미션수행중입니다. 종료후 다른미션 가능합니다")
                            return
                        }
                        
                        self.startMission()
                }
                
                
            } else {
                CircleButton(
                    type: .image(self.imaPath),
                    isSelected: self.isCompleted){ _ in
                        self.appSceneObserver.event = .toast("완료 미션 입니다.")
                }
            }
            if !self.isPlay {
                CircleButton(
                    type: .text("강제완료"),
                    isSelected: self.isCompleted){ _ in
                        self.walkManager.forceCompleteMission()
                }
                
                CircleButton(
                    type: .icon(Asset.icon.goal),
                    isSelected: self.isViewRoute){ _ in
                        if self.isViewRoute {
                            self.isViewRoute = false
                            self.route = nil
                            self.viewModel.playEvent = .clearViewRoute
                            
                        } else {
                            self.walkManager.getRoute(mission: data)
                        }
                }
            }
            
        }
        .onReceive(self.walkManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .getRoute(let route) :
                self.route = route
                self.isViewRoute = true
            case .startMission(let mission): self.updateMission(mission)
            case .endMission(let mission) : self.updateMission(mission)
            default: break
            }
        }
        .onAppear{
            self.updateMission(self.data)
        }
        .onDisappear{
            if self.isViewRoute {
                self.viewModel.playEvent = .clearViewRoute
            }
        }
    }//body
    @State var route:Route? = nil
    @State var isViewRoute:Bool = false
    @State var isPlay:Bool = false
    @State var isCompleted:Bool = false
    @State var imaPath:String? = nil
    private func startMission(){
        self.walkManager.startMission(data, route: self.route)
        self.appSceneObserver.event = .toast("미션을 시작합니다")
        self.close()
    }
    private func updateMission(_ data:Mission){
        if data != self.data {return}
        self.isPlay = self.data.isStart
        self.isCompleted = self.data.isCompleted
        self.imaPath = self.data.pictureUrl
    }
}

#if DEBUG
struct MissionControl_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            MissionControl(
                data:.init()
            ){
                
            }
            .frame( alignment: .center)
        }
        .background(Color.app.white)
        .environmentObject(AppSceneObserver())
        .environmentObject(WalkManager(dataProvider: DataProvider(), locationObserver: LocationObserver()))
        .environmentObject(DataProvider())
    }
}
#endif
