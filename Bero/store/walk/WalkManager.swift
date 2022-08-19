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
    case start, end, startMission(Mission), endMission(Mission), completedMission(Mission), getRoute(Route),
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
class WalkManager:ObservableObject, PageProtocol{
    private let locationObserver:LocationObserver
    private let dataProvider:DataProvider
    private var anyCancellable = Set<AnyCancellable>()
    
    private(set) var missions:[Mission] = []
    private(set) var missionUsers:[Mission] = []
    private(set) var places:[Place] = []
    private(set) var startTime:Date = Date()
    
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
        self.missions = []
        self.missionUsers = []
        self.places = []
        self.updateMapStatus(location)
    }
    func updateMapStatus(_ location:CLLocation){
        if !self.missions.isEmpty {
            if let distence = self.missions.first?.destination?.distance(from: location) {
                if distence == 2000 {
                    DataLog.d("already updated", tag: self.tag)
                    self.updateCheckAnotherStatus(location)
                    return
                }
                self.event = .changeMapStatus
            } else {
                DataLog.d("already updated", tag: self.tag)
                //self.updateCheckAnotherStatus(location)
                return
            }
        }
        self.requestMapStatus(location)
    }
    
    func startWalk() {
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
    
    func endWalk() {
        self.locationObserver.requestMe(false, id:self.tag )
        self.endMission()
        self.end()
    }
    
    @discardableResult
    func getRoute(mission:Mission)->Bool{
        guard let me = self.currentLocation else {return false}
        guard let goal = mission.destination else {return false}
        self.dataProvider.requestData(q: .init(id: self.tag, type: .requestRoute(departure: me, destination: goal), isOptional: true))
        return true
    }
    func clearRoute(){
        self.currentRoute = nil
    }
    
    func startMission(_ mission:Mission){
        self.currentMission = mission
        self.currentRoute =  nil
        self.currentDistenceFromMission = nil
        self.event = .startMission(mission)
    }
    func endMission(){
        guard let mission = self.currentMission else {return}
        self.currentMission = nil
        self.currentRoute =  nil
        self.currentDistenceFromMission = nil
        self.event = .endMission(mission)
    }
    
    private func start(){
        self.startTime = Date()
        self.event = .start
        self.status = .walking
    }
    private func end(){
        self.event = .end
        self.status = .ready
        self.walkTime = 0
        self.walkDistence = 0
    }
    
    private func requestLocation() {
        let status = self.locationObserver.status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.start()
            self.locationObserver.requestMe(true, id:self.tag)
            
        } else if status == .denied {
            self.error = .accessDenied
        } else {
            self.locationObserver.requestWhenInUseAuthorization()
        }
    }
    private func updateLocation(_ loc:CLLocation) {
        if let prev = self.currentLocation {
            let diff = loc.distance(from: prev)
            self.walkDistence += diff
        }
        self.walkTime = Date().timeIntervalSince(self.startTime)
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
    private func missionCompleted(_ mission:Mission){
        self.currentMission = nil
        self.event = .completedMission(mission)
    }
    
    private func requestMapStatus(_ location:CLLocation){
        self.isMapLoading = true
        self.dataProvider.requestData(q: .init(id: self.tag, type: .requestNewMission(location, distance: 2000), isOptional: true))
        //self.updateCheckAnotherStatus(location)
    }
    private func updateCheckAnotherStatus(_ location:CLLocation){
        if self.places.isEmpty {
            self.dataProvider.requestData(q: .init(id: self.tag, type: .getPlace(location), isOptional: true))
        }
        if self.missionUsers.isEmpty {
            self.dataProvider.requestData(q: .init(id: self.tag, type: .searchMission(.all, .User, location: location, distance: 2000), isOptional: true))
        }
    }
    
    
    func respondApi(_ res:ApiResultResponds){
        if !res.id.hasPrefix(self.tag) {return}
        switch res.type {
        case .requestNewMission :
            self.isMapLoading = false
            if let datas = res.data as? [MissionData] {
                self.missions = datas.map{Mission().setData($0)}
                self.event = .updatedMissions
            }
        case .searchMission :
            if let datas = res.data as? [MissionData] {
                self.missionUsers = datas.map{Mission().setData($0)}
                self.event = .updatedUsers
            }
        case  .getPlace :
            if let datas = res.data as? [PlaceData] {
                self.places = datas.map{Place().setData($0)}
                self.event = .updatedPlaces
            }
        case .requestRoute :
            if let datas = res.data as? [MissionRoute] {
                if datas.isEmpty {
                    self.error = .getRoute
                } else {
                    let route = Route().setData(datas.first!)
                    if self.currentMission != nil {
                        self.currentRoute = route
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
