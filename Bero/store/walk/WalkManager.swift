//
//  WalkModel.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/15.
//

import Foundation
import Combine
import CoreLocation
import GooglePlaces
enum WalkEvent {
    case start, end, completed(Mission), startMission(Mission), endMission(Mission), completedMission(Mission), getRoute(Route),
         changeMapStatus, updatedMissions, updatedPlaces , updatedUsers,
         findWaypoint(index:Int, total:Int)
    
    var pushTitle:String? {
        switch self {
        case .endMission :
            return "Mission Complete"
        default : return nil
        }
    }
    var pushText:String? {
        switch self {
        case .endMission(let mission) :
            return mission.description
        default : return nil
        }
    }
}
enum WalkError {
    case accessDenied, getRoute, updatedMissions
}
enum WalkStatus {
    case ready, walking
}
extension WalkManager {
    static let distenceUnit:Double = 200000
}



class WalkManager:ObservableObject, PageProtocol{
    private let locationObserver:LocationObserver
    private let dataProvider:DataProvider
    private var anyCancellable = Set<AnyCancellable>()
    private(set) var missions:[Mission] = []
    private(set) var missionUsers:[Mission] = []
    private(set) var places:[Place] = []
    private(set) var startTime:Date = Date()
    private(set) var startLocation:CLLocation? = nil
    private(set) var completedMissions:[Int] = []
    private(set) var completedWalk:Mission? = nil
    @Published private(set) var event:WalkEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var error:WalkError? = nil {didSet{ if error != nil { error = nil} }}
    @Published private(set) var status:WalkStatus = .ready
    @Published private(set) var walkTime:Double = 0
    @Published private(set) var walkDistence:Double = 0
    @Published private(set) var currentMission:Mission? = nil
    @Published private(set) var currentRoute:Route? = nil
    @Published private(set) var currentLocation:CLLocation? = nil
    @Published private(set) var isMapLoading:Bool = false
    @Published private(set) var currentDistenceFromMission:Double? = nil
    
    init(
        dataProvider:DataProvider,
        locationObserver:LocationObserver){
        self.locationObserver = locationObserver
        self.dataProvider = dataProvider
    }
    
    func resetMapStatus(_ location:CLLocation){
        if self.currentMission == nil {
            self.missions = []
        }
        self.missionUsers = []
        self.places = []
        self.updateMapStatus(location)
    }
    
    func updateMapStatus(_ location:CLLocation){
        if !self.missions.isEmpty {
            if let distence = self.missions.first?.destination?.distance(from: location) {
                if distence <= Self.distenceUnit {
                    DataLog.d("already updated", tag: self.tag)
                    self.updateCheckAnotherStatus(location)
                    return
                }
                self.event = .changeMapStatus
                self.resetMapStatus(location)
                return
            } else {
                DataLog.d("already updated", tag: self.tag)
                self.updateCheckAnotherStatus(location)
                return
            }
        }
        self.requestMapStatus(location)
    }
    
    func startMap() {
        if self.status == .walking && self.currentLocation != nil {return}
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
                
            default : break
            }
        }).store(in: &anyCancellable)
        self.requestLocation()
    }
    
    func endMap() {
        self.missions.forEach{
            $0.isSelected = false
        }
        self.currentMission?.isSelected = false
        if self.status == .ready {
            self.locationObserver.requestMe(false, id:self.tag)
        }
    }
    
    func startWalk(){
        self.startTime = Date()
        self.startLocation = self.currentLocation
        self.event = .start
        self.status = .walking
        self.startTimer()
    }
    
    func completeWalk(){
        let mission = Mission().setData(self)
        self.completedWalk = mission
        self.event = .completed(mission)
    }
    
    func endWalk(){
        self.completedWalk = nil
        self.walkTime = 0
        self.walkDistence = 0
        self.completedMissions = []
        self.endMission()
        self.endTimer()
        self.event = .end
        self.status = .ready
    }
    
    func startMission(_ mission:Mission, route:Route? = nil){
        self.currentMission = mission
        if let loc = self.currentLocation {
            mission.start(location: loc, walkDistence:self.walkDistence)
        }
        self.currentRoute = route
        self.currentDistenceFromMission = nil
        self.event = .startMission(mission)
    }
    
    func endMission(imgPath:String? = nil, missionId:Int? = nil){
        guard let mission = self.currentMission else {return}
        if let id = missionId {
            self.completedMissions.append(id)
            mission.end(isCompleted:true, imgPath: imgPath)
        } else {
            mission.end(isCompleted:false)
        }
        self.currentMission = nil
        self.currentRoute =  nil
        self.currentDistenceFromMission = nil
        self.event = .endMission(mission)
    }
    func forceCompleteMission(){
        guard let mission = self.currentMission else {return}
        self.missionCompleted(mission)
    }
    private func missionCompleted(_ mission:Mission){
        //self.currentMission = nil
        mission.completed(walkDistence: self.walkDistence)
        self.event = .completedMission(mission)
    }
    
    
    @discardableResult
    func getRoute(mission:Mission)->Bool{
        guard let me = self.currentLocation else {return false}
        guard let goal = mission.destination else {return false}
        self.dataProvider.requestData(q: .init(id: self.tag,
                                               type: .requestRoute(departure: me, destination: goal, missionId: mission.missionId.description),
                                               isOptional: true))
        return true
    }
    
    @discardableResult
    func getRoute(goal:CLLocation)->Bool{
        guard let me = self.currentLocation else {return false}
        self.dataProvider.requestData(q: .init(id: self.tag, type: .requestRoute(departure: me, destination: goal), isOptional: true))
        return true
    }
    
    func clearRoute(){
        self.currentRoute = nil
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
            return
        }
        if let prev = self.currentLocation {
            let diff = loc.distance(from: prev)
            self.walkDistence += diff
        }
        self.currentLocation = loc
        guard let mission = self.currentMission else {return}
        guard let destination = mission.destination else {return}
        let distance = destination.distance(from: loc)
        self.currentDistenceFromMission = distance
        if distance < 10 {
            self.missionCompleted(mission)
            return
        }
        guard let waypoints = self.currentRoute?.waypoints else {return}
        guard let find = waypoints.firstIndex(where: {$0.distance(from: loc) < 5}) else {return}
        self.event = .findWaypoint(index: find, total:waypoints.count)
    }
    
    
    
    private func requestMapStatus(_ location:CLLocation){
        self.isMapLoading = true
        self.dataProvider.requestData(q: .init(id: self.tag, type: .requestNewMission(location, distance: Self.distenceUnit), isOptional: true))
        self.updateCheckAnotherStatus(location)
    }
    
    private func updateCheckAnotherStatus(_ location:CLLocation){
        if self.places.isEmpty {
            self.dataProvider.requestData(q: .init(id: self.tag, type: .getPlace(location, distance: Self.distenceUnit), isOptional: true))
        }
        if self.missionUsers.isEmpty {
            self.dataProvider.requestData(q: .init(id: self.tag, type: .searchMission(.all, .User, location: location, distance: Self.distenceUnit), isOptional: true))
        }
    }
    
    private var timer:AnyCancellable?
    private func startTimer(){
        self.timer = Timer.publish(
            every: 1.0, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.walkTime = Date().timeIntervalSince(self.startTime)
            }
    }
    
    private func endTimer(){
        self.timer?.cancel()
        self.timer = nil
    }
    
    func respondApi(_ res:ApiResultResponds){
        if !res.id.hasPrefix(self.tag) {return}
        switch res.type {
        case .requestNewMission :
            self.isMapLoading = false
            if let datas = res.data as? [MissionData] {
                self.missions = datas.map{Mission().setData($0, type: .new)}
                self.event = .updatedMissions
            }
        case .searchMission :
            if let datas = res.data as? [MissionData] {
                self.missionUsers = datas.map{Mission().setData($0, type: .user)}
                self.event = .updatedUsers
            }
        case  .getPlace :
            if let datas = res.data as? [PlaceData] {
                self.places = datas.map{Place().setData($0)}
                self.event = .updatedPlaces
            }
        case .requestRoute(_,_,let id) :
            if let datas = res.data as? [MissionRoute] {
                if datas.isEmpty {
                    self.error = .getRoute
                } else {
                    let route = Route().setData(datas.first!)
                    if self.currentMission?.missionId.description == id {
                        self.currentRoute = route
                        return
                    }
                    self.event = .getRoute(route)
                }
            } else {
                self.error = .getRoute
            }
       
        default : break
        }
    }
    
    func errorApi(_ err:ApiResultError, appSceneObserver:AppSceneObserver?){
        switch err.type {
        case .requestNewMission :
            self.isMapLoading = false
            self.error = .updatedMissions
        case .requestRoute :
            self.error = .getRoute
        default : break
        }
    }
}
