//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps
import GooglePlaces
import QuartzCore


enum PlayMapUiEvent {
    case resetMap, clearViewRoute
}

enum PlayMapEffectEvent {
    case missionPlayStart
}


class PlayMapModel:MapModel{
    @Published var playUiEvent:PlayMapUiEvent? = nil{
        didSet{
            if playUiEvent != nil { self.playUiEvent = nil }
        }
    }
    @Published var playEffectEvent:PlayMapEffectEvent? = nil{
        didSet{
            if playEffectEvent != nil { self.playEffectEvent = nil }
        }
    }
    @Published var componentHidden:Bool = false
    
}
extension PlayMap {
    static let uiHeight:CGFloat = 130
    static let zoomRatio:Float = 17.0
    static let zoomCloseup:Float = 18.5
    static let zoomOut:Float = 16.0
    static let zoomFarAway:Float = 15
    static let mapMoveDuration:Double = 0.5
    static let mapMoveAngle:Double = 30
    static let routeViewDuration:Double = 3
}

struct PlayMap: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
   
    @Binding var isFollowMe:Bool
    @Binding var isForceMove:Bool
    var bottomMargin:CGFloat = 0
    var body: some View {
        CPGoogleMap(
            viewModel: self.viewModel,
            pageObservable: self.pageObservable
        )
        .onReceive(self.walkManager.$currentLocation){ loc in
            guard let loc = loc else {return}
            self.move(loc)
        }
        
        .onReceive(self.walkManager.$status){ status in
            switch status {
            case .ready :
                self.isWalk = false
            case .walking :
                self.isWalk = true
            }
            self.resetMap()
        }
        .onReceive(self.walkManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .changeMapStatus : self.viewModel.uiEvent = .clearAll(nil)
            case .getRoute(let route) : self.viewRoute(route)
            case .updatedMissions : self.onMarkerUpdate()
            case .updatedPlaces : self.onMarkerUpdate()
            case .updatedUsers : self.onMarkerUpdate()
            case .startMission(let mission): self.onMissionStart(mission)
            case .endMission(let mission) : self.onMissionEnd(mission)
            default: break
            }
        }
        .onReceive(self.walkManager.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .moveMap(let loc) : self.moveLocation(loc)
      
            }
        }
        .onReceive(self.viewModel.$playUiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .resetMap : self.resetMap()
            case .clearViewRoute : self.clearCurrentViewRoute()
            }
        }
        .onAppear{
            self.viewModel.zoom = Self.zoomRatio
            UIApplication.shared.isIdleTimerDisabled = true
            self.onMarkerUpdate()
            
        }
        .onDisappear(){
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }//body
   
   
    @State var location:CLLocation? = nil
    @State var isWalk:Bool = false
    @State var isInit:Bool = false
    
    private func onMarkerUpdate(){
        let zip:[MapUiEvent] = [
            .clearAll(),
            .addMarkers(self.getMissions(mission: self.walkManager.currentMission)),
            .addMarkers(self.getUsers()),
            .addMarkers(self.getPlaces())
        ]
        self.viewModel.uiEvent = .zip(zip)
    }
    
    private func move(_ loc:CLLocation){
        if self.isInit {
            self.moveMe(loc)
            return
        }
        self.resetMap()
    }
    
    private func moveLocation(_ loc:CLLocation){
        self.viewModel.uiEvent = .move(loc, rotate: 0, zoom: Self.zoomCloseup, duration: Self.mapMoveDuration)
        self.forceMoveLock()
    }
    
    private func resetMap(){
        if self.isForceMove {return}
        self.meIcon = nil
        self.location = self.walkManager.currentLocation
        self.viewModel.angle = self.isFollowMe ? Self.mapMoveAngle : 0
        self.viewModel.zoom = self.isFollowMe ? Self.zoomCloseup : Self.zoomRatio
        if let loc = self.location {
            self.isInit = true
            self.viewModel.uiEvent = .move(loc, duration:Self.mapMoveDuration)
            self.forceMoveLock(){
                self.moveMe(loc, isMove: true)
            }
        }
    }
    
    @State var meIcon:UIImageView? = nil
    private func moveMe(_ loc:CLLocation, isMove:Bool? = nil){
        if !self.isInit {return}
        if self.isForceMove {return}
        if self.meIcon == nil {
            let icon = UIImage(named: self.isWalk ? Asset.map.myLocationWalk : Asset.map.myLocation)
            let imgv = UIImageView(image: icon)
            self.meIcon = imgv
        }
        guard let icon = self.meIcon else {return}
        
        let user = self.dataProvider.user
        self.location = loc
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude)
        marker.title = "Me"
        let pets = user.pets.filter{$0.isWith}
        let petNames = pets.reduce("", {$0+", "+($1.name ?? "")}).dropFirst()
        marker.snippet = "with " + petNames
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.18)
        marker.iconView = icon
        marker.zIndex = 999
        let move = isMove ?? self.isFollowMe
        var rotate:Double? = nil
        if let target = self.walkManager.currentMission?.destination?.coordinate {
            let targetPoint = CGPoint(x: target.latitude, y: target.longitude)
            let mePoint = CGPoint(x: loc.coordinate.latitude, y: loc.coordinate.longitude)
            rotate = mePoint.getAngleBetweenPoints(target: targetPoint)
        }
        self.viewModel.uiEvent = .me(
            MapMarker(
                id: "me",
                marker:  marker,
                rotation: rotate,
                isRotationMap: move
            ) ,
            follow: move ? loc : nil
        )
    }
    
    private func onMissionStart(_ data:Mission){
        let clears = self.getMissions().map({$0.id})
        self.viewModel.uiEvent = .zip([
            .clearAll(clears),
            .addMarkers(self.getMissions(mission: self.walkManager.currentMission))
        ])
        if let goal = data.destination {
            self.walkManager.getRoute(goal: goal)
        } else {
            self.onMissionPlay()
        }
    }
    private func onMissionPlay(){
        self.viewModel.playEffectEvent = .missionPlayStart
        self.viewModel.componentHidden = false
        self.isFollowMe = true
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
            self.resetMap()
        }
    }
    private func onMissionEnd(_ data:Mission){
        //let marker:MapMarker = .init(id:data.missionId.description, marker: self.getMissionMarker(data))
        var zip:[MapUiEvent] = []
        zip.append(.addMarkers(self.getMissions()))
        self.viewModel.uiEvent = .zip(zip)
    }
    
    
    private func getMissions(mission:Mission? = nil)->[MapMarker]{
        if let mission = mission {
            return [.init(id:mission.missionId.description, marker: self.getMissionMarker(mission))]
        }
        let datas = self.walkManager.missions.filter{$0.destination != nil}
        let markers:[MapMarker] = datas.map{ data in
            return .init(id:data.missionId.description, marker: self.getMissionMarker(data))
        }
        return markers
            
    }
    
    
    private func getUsers()->[MapMarker]{
        let datas = self.walkManager.missionUsers.filter{
            $0.destination != nil
        }
        let markers:[MapMarker] = datas.map{ data in
            return .init(id:data.missionId.description, marker: self.getUserMarker(data))
        }
        return markers
    }
    
    private func getPlaces()->[MapMarker]{
        let datas = self.walkManager.places.filter{$0.location != nil && $0.googlePlaceId?.isEmpty == false}
        let markers:[MapMarker] = datas.map{ data in
            return .init(id:data.googlePlaceId ?? "", marker: self.getPlaceMarker(data))
        }
        return markers
    }
    private func viewRoute(_ route:Route){
        guard let loc = route.waypoints.last else {
            self.viewModel.uiEvent = .clearAllRoute
            return
        }
        let isMissionPlay = self.walkManager.currentMission != nil
        let lines = self.getRoutes(route, color: isMissionPlay ? Color.brand.primary : Color.brand.secondary).map{ MapRoute(line:$0) }
        self.viewModel.uiEvent = .zip([
            .clearAllRoute,
            .move(isMissionPlay
                  ? loc
                  : self.location ?? loc,
                  zoom: Self.zoomFarAway,
                  duration: Self.mapMoveDuration),
            .addRoutes(lines)
        ])
        self.viewModel.componentHidden = true
        self.pagePresenter.hiddenAllPopup()
        self.forceMoveLock(delay: Self.routeViewDuration){
            self.viewModel.uiEvent = .clearAllRoute
            self.viewModel.componentHidden = false
            self.pagePresenter.viewAllPopup()
            if isMissionPlay {
                self.onMissionPlay()
            }
        }
        
    }
    
    private func clearCurrentViewRoute(){
        self.viewModel.uiEvent = .clearAllRoute
    }
    

    private func forceMoveLock(delay:Double = 0, closer:(() -> Void)? = nil){
        self.isForceMove = true
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.mapMoveDuration + delay) {
            self.isForceMove = false
            closer?()
        }
    }
}


