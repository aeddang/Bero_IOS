//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import GoogleMaps

struct MissionView: PageComponent, Identifiable{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var geometry:GeometryProxy? = nil
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    let id:String = UUID().uuidString
    let mission:Mission
    var body: some View {
        InfinityScrollView(
            viewModel: self.infinityScrollModel,
            axes: .vertical,
            scrollType: .vertical(isDragEnd: false),
            showIndicators : false,
            marginVertical: Dimen.margin.medium,
            marginHorizontal: 0,
            spacing:Dimen.margin.regularExtra,
            isRecycle: false,
            useTracking: true
        ){
            PlaceInfo(
                pageObservable: self.pageObservable,
                sortIconPath: self.mission.place?.icon,
                sortTitle: self.mission.place?.name,
                title: self.mission.title,
                description: self.mission.place?.vicinity,
                distance: self.distance,
                goal: self.mission.destination
            )
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            HStack(spacing:Dimen.margin.micro){
                RewardInfo(
                    type: .exp,
                    value: self.mission.exp.toInt()
                )
                RewardInfo(
                    type: .point,
                    value: self.mission.point
                )
               
                
                FillButton(
                    type: .fill,
                    text:
                    self.isCompleted
                    ? String.button.missionComplete
                    : self.isPlay ? String.button.stop : String.button.startMission,
                    size: Dimen.button.regular,
                    color: self.isPlay ? Color.app.black : Color.app.white,
                    gradient:self.isPlay ?nil : Color.app.orangeGradient,
                    isActive: !self.isCompleted
                ){_ in
                    if self.isCompleted {
                        return
                    }
                    self.start()
                }
                
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            if SystemEnvironment.isTestMode {
                if self.isPlay {
                    FillButton(
                        type: .fill,
                        text:"완료 테스트용",
                        size: Dimen.button.regular
                    ){ _ in
                        self.walkManager.forceCompleteMission()
                    }
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                }
            }
            if let path = self.imaPath {
                ImageView(url: path,
                          contentMode: .fill,
                          noImg: Asset.noImg16_9)
                .modifier(Ratio16_9(geometry: self.geometry, horizontalEdges: Dimen.app.pageHorinzontal))
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
                .padding(.horizontal, Dimen.app.pageHorinzontal)
            }
        }
        .background(Color.app.white)
        .onReceive(self.walkManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .getRoute(let route) :
                self.route = route
                self.isViewRoute = true
            case .startMission(let mission):
                if self.mission.missionId == mission.missionId {
                    self.updateMission()
                }
            case .endMission(let mission) :
                if self.mission.missionId == mission.missionId {
                    self.updateMission()
                }
            default: break
            }
        }
        .onAppear{
            self.updateMission()
        }
        .onDisappear{
            if self.isViewRoute {
                //self.viewModel.playEvent = .clearViewRoute
            }
        }
    }
    @State var route:Route? = nil
    @State var isViewRoute:Bool = false
    @State var isCompleted:Bool = false
    @State var distance:Double = 0
    @State var isPlay:Bool = false
    @State var imaPath:String? = nil
    
    private func updateMission(){
        self.isCompleted = self.mission.isCompleted
        self.isPlay = self.mission.isStart
        self.imaPath = self.mission.pictureUrl
        if let loc = self.walkManager.currentLocation, let destination = self.mission.destination {
            self.distance = destination.distance(from: loc)
        }
    }
    
    private func start(){
        if self.dataProvider.user.pets.isEmpty {
            self.appSceneObserver.sheet = .select(
                String.alert.addDogTitle,
                String.alert.addDogText,
                image:Asset.image.addDog,
                [String.button.later,String.button.ok]){ idx in
                    if idx == 1 {
                        self.pagePresenter.openPopup(PageProvider.getPageObject(.addDog))
                    }
                }
            return
        }
        
        if self.walkManager.status != .walking {
            self.appSceneObserver.alert = .confirm(nil, String.alert.missionStartNeedWalkConfirm){ isOk in
                if isOk {
                    self.walkManager.startWalk()
                    DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                        self.startMission()
                    }
                }
            }
            return
        }
        if self.isPlay {
            self.appSceneObserver.alert = .confirm(nil, String.alert.missionCancelConfirm){ isOk in
                if isOk {
                    self.walkManager.endMission()
                }
            }
            return
        }
        if self.walkManager.currentMission != nil {
            self.appSceneObserver.event = .toast(String.alert.missionStartPrevMissionCancel)
            return
        }
        self.startMission()
    }
    
    private func startMission(){
        self.walkManager.startMission(self.mission)
        //self.appSceneObserver.event = .toast(String.alert.missionStart)
        // self.pagePresenter.closePopup(self.pageObservable.pageObject?.id)
    }
}


/*
#if DEBUG
struct PlaceView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlaceView(
                place: Place()
            )
        }
        .padding(.all, 10)
        .background(Color.app.white)
        .environmentObject(PagePresenter())
        .environmentObject(PageSceneObserver())
        .environmentObject(Repository())
        .environmentObject(DataProvider())
        .environmentObject(AppSceneObserver())
    }
}
#endif
*/
