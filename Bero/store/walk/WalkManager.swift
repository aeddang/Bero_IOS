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
    case start, end, startMission(Mission), completedMission(Mission), getRoute(Route),
         updatedMissions, changeMissions
}
enum WalkError {
    case accessDenied, getRoute, updatedMissions
}
enum WalkStatus {
    case ready, walking, mission
}
class WalkManager:ObservableObject, PageProtocol{
    private let locationObserver:LocationObserver
    private let dataProvider:DataProvider
    private var anyCancellable = Set<AnyCancellable>()
    
    private(set) var missions:[Mission] = []
    private(set) var startTime:Date = Date()
    
    @Published private(set) var event:WalkEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var error:WalkError? = nil {didSet{ if error != nil { error = nil} }}
    @Published private(set) var status:WalkStatus = .ready
    
    @Published private(set) var walkTime:Double = 0
    @Published private(set) var walkDistence:Double = 0
    @Published private(set) var currentMission:Mission? = nil
    @Published private(set) var currentLocation:CLLocation? = nil
    
    @Published private(set) var isMissionLoading:Bool = false
    
    init(
        dataProvider:DataProvider,
        locationObserver:LocationObserver){
        self.locationObserver = locationObserver
        self.dataProvider = dataProvider
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
                if let prev = self.currentLocation {
                    let diff = loc.distance(from: prev)
                    self.walkDistence += diff
                }
                self.walkTime = Date().timeIntervalSince(self.startTime)
                self.currentLocation = loc
                if self.missions.isEmpty {
                    
                }
            default : break
            }
        }).store(in: &anyCancellable)
        self.requestLocation()
    }
    
    func endWalk() {
        self.locationObserver.requestMe(false, id:self.tag )
        self.end()
    }
    
    func getRoute(mission:Mission)->Bool{
        guard let me = self.currentLocation else {return false}
        guard let goal = mission.destination else {return false}
        self.dataProvider.requestData(q: .init(id: self.tag, type: .requestRoute(departure: me, destination: goal), isOptional: true))
        return true
    }
    
    func startMission(_ mission:Mission){
        self.currentMission = mission
    }
    func endMission(){
        self.currentMission = nil
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
        self.locationObserver.requestMe(true, id:self.tag)
    }
    
    private func start(){
        self.startTime = Date()
        self.event = .start
        self.status = .walking
       
    }
    private func end(){
        self.missions = []
        self.event = .end
        self.status = .ready
    }
    
    func getMission(_ location:CLLocation){
        if !self.missions.isEmpty {
            if let distence = self.missions.first?.destination?.distance(from: location) {
                if distence == 2000 {
                    return
                }
                self.event = .changeMissions
            } else {
                return
            }
        }
        self.isMissionLoading = true
        self.dataProvider.requestData(q: .init(id: self.tag, type: .requestNewMission(location: location), isOptional: true))
    }
    
    func respondApi(_ res:ApiResultResponds){
        switch res.type {
        case .requestNewMission :
            if let datas = res.data as? [MissionData] {
                self.missions = datas.map{Mission().setData($0)}
                self.event = .updatedMissions
            }
            
        case .requestRoute :
            if let datas = res.data as? [MissionRoute] {
                if datas.isEmpty {
                    self.error = .getRoute
                } else {
                    let route = Route().setData(datas.first!)
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
        case .requestNewMission :  self.error = .updatedMissions
        case .requestRoute :  self.error = .getRoute
        default : break
        }
    }
}
