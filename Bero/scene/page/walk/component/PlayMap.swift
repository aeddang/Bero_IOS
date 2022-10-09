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
    case missionPlayStart, viewRoute(duration:Double)
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
    static let zoomDefault:Float = 17.0
    static let zoomOut:Float = 16.0
    static let zoomFarAway:Float = 15
    static let mapMoveDuration:Double = 0.5
    static let mapMoveAngle:Double = 30
    static let routeViewDuration:Double = 4
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
        ZStack(alignment: .bottom){
            CPGoogleMap(
                viewModel: self.viewModel,
                pageObservable: self.pageObservable
            )
            if self.isRouteView {
                FillButton(
                    type: .fill,
                    text: String.button.close,
                    color: Color.app.black,
                    isActive: true
                ){_ in
                    self.viewRouteEnd()
                }
                .modifier(PageAll())
                
            }
        }
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
            case .moveMap(let loc) :
                self.isFollowMe = false
                self.moveLocation(loc)
            case .hiddenRoute : self.viewRouteEnd()
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
    @State var isRouteView:Bool = false
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
            self.viewModel.uiEvent = .move(loc, rotate: 0 , duration:Self.mapMoveDuration)
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
            let icon = UIImage(named: Asset.map.myLocationWalk)
            let imgv = UIImageView(image: icon)
            self.meIcon = imgv
        }
        self.location = loc
        let move = isMove ?? self.isFollowMe
        var rotate:Double? = nil
        if let target = self.walkManager.currentMission?.destination?.coordinate {
            let targetPoint = CGPoint(x: target.latitude, y: target.longitude)
            let mePoint = CGPoint(x: loc.coordinate.latitude, y: loc.coordinate.longitude)
            rotate = mePoint.getAngleBetweenPoints(target: targetPoint)
        }
        self.viewModel.uiEvent = .me(
            self.getMyMarker(rotate: rotate, move: move),
            follow: move ? loc : nil
        )
    }
    
    @State var isMissionStart:Bool = false
    private func onMissionStart(_ data:Mission){
        if data.destination != nil {
            self.walkManager.viewRoute(mission: data)
        } else {
            self.onMissionPlay()
        }
    }
    private func onMissionPlay(){
        if !self.isMissionStart {
            self.isMissionStart = true
            self.viewModel.playEffectEvent = .missionPlayStart
        }
        self.viewModel.componentHidden = false
        self.isFollowMe = true
        self.onMarkerUpdate()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.resetMap()
            
        }
    }
    private func onMissionEnd(_ data:Mission){
        //let marker:MapMarker = .init(id:data.missionId.description, marker: self.getMissionMarker(data))
        self.isMissionStart = false
        var zip:[MapUiEvent] = []
        zip.append(.addMarkers(self.getMissions()))
        self.viewModel.uiEvent = .zip(zip)
    }
    
    private func getMyMarker(rotate:Double? = nil, move:Bool = false)->MapMarker{
        let loc = self.location ?? .init()
        let marker = self.getMe(loc)
        let mapMarker = MapMarker(
            id: "me",
            marker:  marker,
            rotation: rotate,
            isRotationMap: move
        )
        return mapMarker
            
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
        let isAuto = !self.isMissionStart && self.walkManager.currentMission != nil
        var focus:CLLocation = loc
        var scale:Float = Self.zoomDefault
        if let me = self.walkManager.currentLocation {
            focus = .init(
                latitude: (loc.coordinate.latitude + me.coordinate.latitude) / 2.0 ,
                longitude: (loc.coordinate.longitude + me.coordinate.longitude) / 2.0
            )
            let dis = me.distance(from: loc) / 20000  // 거리당 배율
            let factor = Float(23 * dis)
            scale = max(scale - factor, 11)
            DataLog.d("dis " + dis.description, tag: self.tag)
            DataLog.d("scale " + scale.description, tag: self.tag)
        }
        
        let lines = self.getRoutes(route, color: Color.brand.secondary).map{ MapRoute(line:$0) }
        var goalMarker:MapMarker? = nil
        if let data = self.walkManager.viewPlace {
            goalMarker = .init(id:data.googlePlaceId ?? "", marker: self.getPlaceMarker(data))
        }else if let data = self.walkManager.viewMission {
            goalMarker = .init(id:data.missionId.description, marker: self.getMissionMarker(data))
        }
        if let goal = goalMarker {
            self.viewModel.uiEvent = .zip([
                .clearAll(),
                .me(self.getMyMarker()),
                .addMarker(goal),
                .move(focus,
                      zoom: scale,
                      duration: Self.mapMoveDuration),
                .addRoutes(lines)
            ])
        }
        self.viewModel.componentHidden = true
        self.pagePresenter.hiddenAllPopup()
        SoundToolBox().play(snd:Asset.sound.shot)
        if isAuto {
            self.viewModel.playEffectEvent = .viewRoute(duration: Self.routeViewDuration)
        } else {
            self.isFollowMe = false
            self.isRouteView = true
        }
        self.forceMoveLock(delay: isAuto ? Self.routeViewDuration : 0){
            if isAuto {
                self.viewRouteEnd()
            }
        }
        
    }
    private func viewRouteEnd(){
        let isMissionPlay = self.walkManager.currentMission != nil
        self.isRouteView = false
        self.viewModel.componentHidden = false
        self.pagePresenter.viewAllPopup()
        if isMissionPlay {
            SoundToolBox().play(snd:Asset.sound.shotLong)
            self.onMissionPlay()
        } else {
            self.walkManager.viewRouteEnd()
            self.onMarkerUpdate()
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


