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

struct WalkControllBox : PageComponent {
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    @Binding var isFollowMe:Bool
    @Binding var isForceMove:Bool
    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.thin){
            HStack(spacing:Dimen.margin.thin){
                Text(self.status)
                    .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.black))
                Text(Mission.viewDistance(self.walkDistence))
                    .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.black))
                Text(Mission.viewDuration(self.walkTime))
                    .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.black))
            }
            if let mission = self.mission {
                HStack(spacing:Dimen.margin.thin){
                    Text(mission.description ?? mission.place?.name ?? "mission")
                        .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.black))
                    if let distence = self.distenceFromMission {
                        Text(Mission.viewDistance(distence))
                            .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.black))
                    }
                }
            }
          
            HStack(spacing:Dimen.margin.thin){
                ForEach(self.pets) { pet in
                    CircleButton(
                        type: .image(pet.imagePath),
                        isSelected: pet.isWith){ _ in
                            
                    }
                }
            }
            
            HStack(spacing:Dimen.margin.thin){
                CircleButton(
                    type: .icon(self.isWalk ? Asset.icon.pause : Asset.icon.play_circle_filled ),
                    isSelected: self.isWalk){ _ in
                        self.toggleWalk()
                }
                if let mission = self.mission {
                    CircleButton(
                        type: .icon(Asset.icon.paw),
                        isSelected: true){ _ in
                            self.appSceneObserver.alert = .confirm(nil, "미션을 종료 하겠습니까?"){ isOk in
                                if isOk {
                                    self.walkManager.endMission()
                                }
                            }
                    }
                    CircleButton(
                        type: .icon(Asset.icon.goal),
                        isSelected: self.route != nil){ _ in
                            self.toggleRoute(mission:mission)
                    }
                }
                CircleButton(
                    type: .icon(Asset.icon.my_location),
                    isSelected: self.isFollowMe)
                { _ in
                    self.isFollowMe.toggle()
                    self.viewModel.playEvent = .resetMap
                }
                .padding(.trailing, Dimen.margin.regular)
                
                CircleButton(
                    type: .icon(Asset.icon.refresh),
                    isSelected: false){ _ in
                        self.resetMap()
                }
                
               
            }
        }
        .padding(.all, Dimen.margin.thin)
        .modifier(MatchHorizontal(height: 160))
        .background(Color.app.whiteDeep.opacity(0.7))
        .onReceive(self.dataProvider.user.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .addedDog, .deletedDog, .updatedDogs : self.updatedPets()
            case .updatedPlayData :
                break
            default: break
            }
        }
        .onReceive(self.walkManager.$status){ status in
            switch status {
            case .ready :
                self.status = "ready"
                self.isWalk = false
            case .walking :
                self.status = "walking"
                self.isWalk = true
            }
            
        }
        .onReceive(self.walkManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            default: break
            }
        }
        .onReceive(self.walkManager.$currentMission){ mission in
            self.mission = mission
        }
        .onReceive(self.walkManager.$currentRoute){ route in
            self.route = route
        }
        .onReceive(self.walkManager.$currentDistenceFromMission){ distence in
            self.distenceFromMission = distence ?? 0
        }
        .onReceive(self.walkManager.$walkTime){ time in
            self.walkTime = time
        }
        .onReceive(self.walkManager.$walkDistence){ distence in
            self.walkDistence = distence
        }
        .onAppear(){
            self.updatedPets()
            
        }
        
    }//body
    @State var status:String = ""
    @State var mission:Mission? = nil
    @State var route:Route? = nil
    @State var pets:[PetProfile] = []
    @State var distenceFromMission:Double = 0
    @State var walkTime:Double = 0
    @State var walkDistence:Double = 0
    @State var isWalk:Bool = false
    private func updatedPets(){
        self.pets = self.dataProvider.user.pets
    }
    
    private func toggleWalk(){
        if  self.walkManager.currentLocation == nil && !self.isWalk {
            self.appSceneObserver.event = .toast("위치정보를 알수 없습니다")
            return
        }
        if self.mission != nil {
            self.appSceneObserver.alert = .confirm("수행중 미션 있음", "수행중이던 미션은 종료됩니다"){ isOk in
                if isOk {
                    self.walkManager.endWalk()
                }
            }
            return
        }
        if self.isWalk {
            self.walkManager.endWalk()
        } else {
            self.walkManager.startWalk()
        }
    }
    
    private func resetMap(){
        guard let loc = self.walkManager.currentLocation else {
            self.appSceneObserver.event = .toast("위치정보를 알수 없습니다")
            return
        }
        self.walkManager.resetMapStatus(loc)
    }
    
    private func toggleRoute(mission:Mission){
        if self.route != nil {
            self.walkManager.clearRoute()
        } else {
            self.walkManager.getRoute(mission: mission)
        }
    }
}

#if DEBUG
struct WalkControllBox_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            WalkControllBox(isFollowMe: .constant(false), isForceMove: .constant(false)
                
            )
            .frame( alignment: .center)
        }
        .background(Color.app.white)
        .environmentObject(AppSceneObserver())
        .environmentObject(WalkManager(dataProvider: DataProvider(), locationObserver: LocationObserver()))
        .environmentObject(DataProvider())
    }
}
#endif
