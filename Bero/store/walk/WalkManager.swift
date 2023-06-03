//
//  WalkModel.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/15.
//

import Foundation
import Combine
import SwiftUI
import CoreLocation
import GooglePlaces
enum WalkEvent {
    case viewTutorial(resource:String),
         start, end, completed(Mission),
         getRoute(Route), endRoute,
         changeMapStatus, updatedMissions, updatedPlaces , updatedUsers,
         findWaypoint(index:Int, total:Int), findPlace(Place),
         updatedPath,
         updateViewLocation(CLLocation)
}

enum WalkUiEvent {
    case moveMap(CLLocation, zoom:Float = PlayMap.zoomCloseup), hiddenRoute, closeAllPopup
}
enum WalkError {
    case accessDenied, getRoute, updatedMissions
}
enum WalkStatus {
    case ready, walking
}

extension WalkManager {
    static var todayWalkCount:Int = 0
    static let distanceUnit:Double = 5000
    static let nearDistance:Double = 20
    static let minDistance:Double = 100
    static let limitedUpdateImageSize:Int = 9
    static func viewSpeed(_ value:Double, unit:String? = String.app.kmPerH) -> String {
        let v = (value / 1000).toTruncateDecimal(n:1)
        if let unit = unit {
            return v + " " + unit
        } else {
            return v
        }
    }
    static func viewDistance(_ value:Double, unit:String? = String.app.km) -> String {
        let v = (value / 1000).toTruncateDecimal(n:2)
        if let unit = unit {
            return v + " " + unit
        } else {
            return v
        }
        
    }
    static func viewDuration(_ value:Double) -> String {
        return value.secToMinString()
    }
    static func getPoint(_ value:Double) -> Int {
        return ceil(value/100).toInt() //+ 5인증샷 점수
    }
    static func getExp(_ value:Double) -> Double {
        return ceil(value/100)
    }
    
    

    enum WalkAniType {
        case tutorial, start
        var path:String{
            switch self {
            case .tutorial: return "tutorial_1"
            case .start: return "tutorial_2"
            }
        }
    }
}

class WalkManager:ObservableObject, PageProtocol{
    var appSceneObserver:AppSceneObserver? = nil
    let locationObserver:LocationObserver
    private var lockScreenManager:PageProtocol? = nil
    private let dataProvider:DataProvider
    private var anyCancellable = Set<AnyCancellable>()
   
    private(set) var missionUsers:[Mission] = []
    private(set) var missionUsersSummary:[Mission] = []
    private(set) var originPlaces:[Place] = []
    private(set) var places:[Place] = []
    private(set) var placesSummary:[Place] = []
    private(set) var startTime:Date = Date()
    private(set) var startLocation:CLLocation? = nil
    private(set) var updateLocation:CLLocation? = nil
    private(set) var updateZipCode:String? = nil
    private(set) var completedMissions:[Int] = []
    private(set) var completedWalk:Mission? = nil
    
    @Published var uiEvent:WalkUiEvent? = nil {didSet{ if uiEvent != nil { uiEvent = nil} }}
    @Published private(set) var event:WalkEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var error:WalkError? = nil {didSet{ if error != nil { error = nil} }}
    @Published private(set) var status:WalkStatus = .ready
    @Published private(set) var walkTime:Double = 0
    @Published private(set) var walkDistance:Double = 0
  
    @Published private(set) var viewMission:Mission? = nil
    @Published private(set) var viewPlace:Place? = nil
    @Published private(set) var currentLocation:CLLocation? = nil
    @Published private(set) var isMapLoading:Bool = false
    @Published private(set) var currentDistanceFromMission:Double? = nil
    @Published private (set) var playPoint:Int = 0
    @Published private (set) var playExp:Double = 0
    @Published private (set) var isSimpleView:Bool = false
    private (set) var walkId:Int? = nil
    private (set) var walkPath:WalkPath? = nil
    private (set) var updateImages:[UIImage] = []
    private (set) var updateImageLocations:[CLLocation] = []
    let nearDistance:Double = WalkManager.nearDistance
    let farDistance:Double = 2000
    let updateTime:Int = 5
    var isBackGround:Bool = false
    init(
        appSceneObserver:AppSceneObserver?,
        dataProvider:DataProvider,
        locationObserver:LocationObserver){
            self.appSceneObserver = appSceneObserver
            self.locationObserver = locationObserver
            self.dataProvider = dataProvider
            if #available(iOS 16.2, *) {
                self.lockScreenManager = LockScreenManager()
            }
            locationObserver.$event.sink(receiveValue: { evt in
                switch evt {
                case .updateAuthorization(let status):
                    if status == .authorizedWhenInUse || status == .authorizedAlways {
                        self.requestLocation()
                    } else {
                        self.error = .accessDenied
                    }
                case .updateLocation(let loc):
                    self.updateLocation(loc)
                    if self.status == .ready {
                        self.locationObserver.requestMe(false, id:self.tag)
                    }
                    
                default : break
                }
            }).store(in: &anyCancellable)
    }
    deinit{
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.endLockScreen()
    }
    
    func firstWalk(){
        self.event = .viewTutorial(resource: WalkAniType.tutorial.path)
    }
    func firstWalkStart(){
        if Self.todayWalkCount < 1 {
            self.event = .viewTutorial(resource: WalkAniType.start.path)
        }
    }
    private func clearAllMapStatus(){
        self.missionUsers = []
        self.originPlaces = []
        self.places = []
        self.missionUsersSummary = []
        self.placesSummary = []
        self.updateLocation = nil
        self.updateZipCode = nil
    }
    
    func resetMapStatus(_ location:CLLocation? = nil){
        self.clearAllMapStatus()
        self.event = .changeMapStatus
        if let loc = location ?? self.currentLocation {
            self.updateMapStatus(loc, isCheckDistence: false)
        }
    }
    
    func clearMapUser(){
        self.missionUsers = []
        self.missionUsersSummary = []
    }
    
    func updateMapStatus(_ location:CLLocation, isCheckDistence:Bool = true){
        if isCheckDistence, let prevLoc = self.updateLocation{
            let distance = prevLoc.distance(from: location)
            if distance <= Self.distanceUnit {
                DataLog.d("already updated", tag: self.tag)
                return
            }
        }
        self.updateMapPlace(location)
        self.updateMapUser(location)
        self.event = .updateViewLocation(location)
    }
    
    func replaceMapStatus(_ location:CLLocation){
        self.clearAllMapStatus()
        self.updateMapPlace(location)
        self.updateMapUser(location)
        self.event = .updateViewLocation(location)
    }

    func updateMapPlace(_ location:CLLocation){
        self.updateLocation = location
        self.locationObserver.convertLocationToAddress(location: location){ address in
            let zip = address.zipCode
            self.updateZipCode = zip
            self.dataProvider.requestData(
                q: .init(
                    id: self.tag,
                    type: .getPlace(location, distance: Self.distanceUnit, zip:zip), isOptional: true))
        }
        //self.filterPlace()
    }
    
    func updateMapUser(_ location:CLLocation){
        if self.missionUsers.isEmpty {
            self.dataProvider.requestData(q:
                    .init(id: self.tag,
                          type: .searchLatestWalk(loc: location, radius: 1000, min: 60000),
                          isOptional: false))
        }
    }
    
    func updateSimpleView(_ view:Bool) {
        if self.status != .walking {
            self.isSimpleView = false
            return
        }
        self.isSimpleView = view
    }
    
    func updateReward(_ exp:Double, point:Int) {
        if self.status != .walking { return }
        self.playPoint += point
        self.playExp += exp
    }
    
    func startMap() {
        if self.status == .walking && self.currentLocation != nil {return}
        self.requestLocation()
    }
    
    func endMap() {
        
    }
    
    func requestWalk(){
        guard let loc = self.currentLocation else {return}
        let withProfiles = self.dataProvider.user.pets.filter{$0.isWith}
        self.dataProvider.requestData(q: .init(id: self.tag, type: .registWalk(loc: loc, withProfiles)))
    }

    private func startWalk(){
        self.startTime = Date()
        self.startLocation = self.currentLocation
        self.event = .start
        self.status = .walking
        self.startTimer()
        self.walkPath = WalkPath()
        self.requestLocation()
        self.updatePath()
        if #available(iOS 16.2, *) , let lsm = self.lockScreenManager as? LockScreenManager {
            lsm.startLockScreen(data: .init(title: String.lockScreen.start))
        }
        guard let loc = self.currentLocation else { return }
        self.updateMapStatus(loc, isCheckDistence: true)
    }
    
    func completeWalk(){
        let mission = Mission().setData(self)
        self.completedWalk = mission
        self.event = .completed(mission)
    }
    
    func endWalk(){
        self.endLockScreen()
        self.completedWalk = nil
        self.walkPath = nil
        self.walkTime = 0
        self.walkDistance = 0
        self.playExp = 0
        self.playPoint = 0
        self.completedMissions = []
        self.updateImages = []
        self.updateImageLocations = []
        self.endTimer()
        self.event = .end
        self.status = .ready
        self.walkId = nil
        self.isSimpleView = false
        self.locationObserver.requestMe(false, id:self.tag)
    }
    
    private func endLockScreen(){
        if #available(iOS 16.2, *) , let lsm = self.lockScreenManager as? LockScreenManager {
            lsm.endLockScreen(data: .init(title: String.lockScreen.end, walkTime:self.walkTime , walkDistance:self.walkDistance))
            self.lockScreenManager = nil
        }
    }
    
    func registPlace(){
        self.filterPlace()
    }
    
    func viewRoute(mission:Mission){
        guard let goal = mission.location else { return }
        self.viewMission = mission
        self.getRoute(goal: goal)
    }
    
    func viewRoute(place:Place){
        guard let goal = place.location else { return }
        self.viewPlace = place
        self.getRoute(goal: goal)
    }
    
    func viewRouteEnd(){
        self.viewMission = nil
        self.viewPlace = nil
        self.event = .endRoute
    }
    
    @discardableResult
    func getRoute(goal:CLLocation)->Bool{
        guard let me = self.currentLocation else {return false}
        self.dataProvider.requestData(q: .init(id: self.tag, type: .requestRoute(departure: me, destination: goal), isOptional: false))
        return true
    }
    func updateAbleCheck()->Bool{
        guard let _ = self.currentLocation else {
            self.appSceneObserver?.event = .toast(String.alert.locationDisable)
            return false
        }
        if self.updateImages.count >= Self.limitedUpdateImageSize {
            self.appSceneObserver?.event = .toast(String.pageText.walkImageLimitedUpdate.replace(Self.limitedUpdateImageSize.description))
            return false
        }
        return true
    }
    func updateStatus(img:UIImage? = nil, thumbImage:UIImage? = nil){
       
        guard let loc = self.currentLocation else {return}
        guard let id = self.walkId else {return}
        self.dataProvider.requestData(q:
                .init(id: self.tag, type: .updateWalk(
                    walkId: id, loc: loc,
                    additionalData: .init(
                        img: img, thumbImg: thumbImage,
                        walkTime: self.walkTime, walkDistance: self.walkDistance)
                ), isOptional: true)
        )
    }
    
    private func requestLocation() {
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationObserver.requestMe(true, id:self.tag)
        } else if status == .denied {
            self.error = .accessDenied
        } else {
            self.locationObserver.requestWhenInUseAuthorization()
        }
    }
    
    private func updateLocation(_ loc:CLLocation) {
        if self.status == .ready {
            self.currentLocation = loc
            if self.places.isEmpty {
                self.filterPlace()
            }
            return
        }
        if let prev = self.currentLocation {
            let diff = loc.distance(from: prev)
            self.walkDistance += diff
        }
        self.currentLocation = loc
        
        self.updateMapStatus(loc)
        if self.isBackGround {
            if #available(iOS 16.2, *) , let lsm = self.lockScreenManager as? LockScreenManager {
                if let place = self.findPlace(loc) {
                    lsm.alertLockScreen(data: .init(
                        title: "FIND",
                        info: (place.title ?? "") + " find!",
                        walkTime: self.walkTime,
                        walkDistance: self.walkDistance))
                } else {
                    lsm.updateLockScreen(data: .init(title: String.lockScreen.walking, walkTime: self.walkTime, walkDistance: self.walkDistance))
                }
            }

        } else {
            self.findPlace(loc)
        }
    }


    private var timer:AnyCancellable?
    private func startTimer(){
        var n = 0
        self.timer = Timer.publish(
            every: 1.0, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.walkTime = Date().timeIntervalSince(self.startTime)
                n += 1
                if n == self.updateTime{
                    self.updateStatus()
                    n = 0
                }
            }
    }
    
    private func endTimer(){
        self.timer?.cancel()
        self.timer = nil
    }
    
    func respondApi(_ res:ApiResultResponds){
        if !res.id.hasPrefix(self.tag) {return} 
        switch res.type {
       
        case .searchLatestWalk :
            if let datas = res.data as? [WalkUserData] {
                self.filterUser(datas: datas)
            }
        case .getPlace :
            if let datas = res.data as? [PlaceData] {
                self.originPlaces = datas.map{Place().setData($0)}
                self.filterPlace()
            }
        case .requestRoute :
            if let datas = res.data as? [WalkRoute] {
                if datas.isEmpty {
                    self.error = .getRoute
                    self.viewRouteEnd()
                } else {
                    let route = Route().setData(datas.first!)
                    self.event = .getRoute(route)
                }
            } else {
                self.error = .getRoute
                self.viewRouteEnd()
            }
        case .registWalk :
            if let data = res.data as? WalkRegistData {
                self.walkId = data.walkId
                self.startWalk()
            }
        case .updateWalk(let walkId, _, let additionalData) :
            if walkId != self.walkId {return}
            if let img = additionalData?.img  {
                self.updateImages.append(img)
                self.updatePath()
                self.appSceneObserver?.event = .check(self.updateImages.count.description + "/" + Self.limitedUpdateImageSize.description, icon:Asset.icon.camera)
            }
        default : break
        }
    }
    
    
    
    func errorApi(_ err:ApiResultError, appSceneObserver:AppSceneObserver?){
        switch err.type {
       
        case .requestRoute :
            self.error = .getRoute
            self.viewRouteEnd()
    
        case .getPlace :
            self.filterPlace()
            
        default : break
        }
    }
    
    private func updatePath(){
        if let loc = self.currentLocation {
            self.updateImageLocations.append(loc)
            self.walkPath?.setData(self.updateImageLocations)
            self.event = .updatedPath
        }
    }
    
    private func filterUser(datas:[WalkUserData]){
        guard let loc = self.currentLocation else {
            DataLog.d("filterUser error notfound me", tag: self.tag)
            return
        }
        let me = self.dataProvider.user.snsUser?.snsID
        self.missionUsers = datas.map{Mission().setData($0)}
            .filter{$0.userId != me}
            .sorted(by: { p1, p2 in
                let distance1 = p1.location?.distance(from: loc) ?? 0
                let distance2 = p2.location?.distance(from: loc) ?? 0
                return distance1 < distance2
            })
            
        var summary:[Mission] = []
        var prev:Mission? = nil
        var idx:Int = 0
        for data in self.missionUsers {
            data.setRange(idx: idx, width: 0)
            idx += 1
            if let loc = data.location {
                if let prevLoc = prev?.location {
                    if prevLoc.distance(from: loc) < self.farDistance {
                        prev?.addCount(loc: loc)
                    } else {
                        let new = Mission().copySummry(origin: data)
                        summary.append(new)
                        prev = new
                    }
                } else {
                    let new = Mission().copySummry(origin: data)
                    summary.append(new)
                    prev = new
                }
            }
        }
        summary.forEach{$0.addCompleted()}
        self.missionUsersSummary = summary
        self.event = .updatedUsers
    }
    
    private func findWayPoint(_ loc:CLLocation){
        /*
        guard let waypoints = self.currentRoute?.waypoints else {return}
        guard let find = waypoints.firstIndex(where: {$0.distance(from: loc) < self.nearDistance}) else {return}
        self.event = .findWaypoint(index: find, total:waypoints.count)
        */
    }
    
    private var finalFind:Place? = nil
    @discardableResult
    private func findPlace(_ loc:CLLocation)->Place?{
        guard let find = self.places.filter({!$0.isMark}).first(where: {$0.location!.distance(from: loc) < self.nearDistance}) else {
            //DataLog.d("findPlace not find", tag: self.tag)
            self.finalFind = nil
            return nil
        }
        if self.finalFind != nil {
            DataLog.d("findPlace already find", tag: self.tag)
            return nil
        }
        self.finalFind = find
        DataLog.d("findPlace find " + (find.title ?? ""), tag: self.tag)
        self.event = .findPlace(find)
        return find
    }
    
    private func filterPlace(){
        guard let loc = self.currentLocation else {
            DataLog.d("filterPlace error notfound me", tag: self.tag)
            return
        }
        DataLog.d("filterPlace start", tag: self.tag)
        let initDatas:[Place] = []
        let datas:[Place] = self.originPlaces
        .sorted(by: { p1, p2 in
            let distance1 = p1.location?.distance(from: loc) ?? 0
            let distance2 = p2.location?.distance(from: loc) ?? 0
            return distance1 < distance2
        })
        
        var count:Int = 0
        let completed = datas.filter{$0.isMark}
        let new = datas.filter{!$0.isMark}
        var fixed:[Place] = []
        let limited = self.nearDistance*5
        for data in new {
            if let loc = data.location {
                if fixed.first(where: { fix in
                    if let fixLoc = fix.location {
                        return fixLoc.distance(from: loc) < limited
                    } else {
                        return false
                    }
                }) == nil {
                    fixed.append(data)
                    count += 1
                } 
            }
            if count == 10 {
                break
            }
        }
        fixed.append(contentsOf: completed)
        var idx:Int = 0
        fixed.forEach{
            $0.setRange(idx: idx, width: 0)
            idx += 1
        }
        DataLog.d("filterPlace end " + fixed.count.description, tag: self.tag)
        self.places = fixed
       
        var summary:[Place] = []
        var prev:Place? = nil
        for data in fixed {
            if let loc = data.location {
                if let prevLoc = prev?.location {
                    if prevLoc.distance(from: loc) < self.farDistance {
                        prev?.addCount(loc: loc)
                    } else {
                        let new = Place().copySummry(origin: data)
                        summary.append(new)
                        prev = new
                    }
                } else {
                    let new = Place().copySummry(origin: data)
                    summary.append(new)
                    prev = new
                }
            }
        }
        summary.forEach{$0.addCompleted()}
        self.placesSummary = summary
        self.event = .updatedPlaces
    }
    
}
