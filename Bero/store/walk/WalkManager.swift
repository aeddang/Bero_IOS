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

enum WalkUiEvent {
    case moveMap(CLLocation)
}
enum WalkError {
    case accessDenied, getRoute, updatedMissions
}
enum WalkStatus {
    case ready, walking
}
extension WalkManager {
    static var todayWalkCount:Int = 0
    static let distenceUnit:Double = 200000
    static func viewSpeed(_ value:Double) -> String {
        return (value * 3600 / 1000).toTruncateDecimal(n:1) + String.app.kmPerH
    }
    static func viewDistance(_ value:Double) -> String {
        return (value / 1000).toTruncateDecimal(n:1) + String.app.km
    }
    static func viewDuration(_ value:Double) -> String {
        return value.secToMinString()
    }
    
    enum SortType{
        case user, mission, place
        
        var icon:String{
            switch self {
            case .user: return Asset.image.profile_dog_default
            case .mission: return Asset.icon.goal
            case .place: return Asset.icon.place
            }
        }
        var title:String{
            switch self {
            case .user: return String.app.dogs
            case .mission: return String.app.missions
            case .place: return String.app.stores
            }
        }
        
        var filter:[Filter]{
            switch self {
            case .user: return [Filter.all, Filter.friends, Filter.notUsed]
            case .mission: return [Filter.all, Filter.complete, Filter.new, Filter.notUsed]
            case .place: return [Filter.shop, Filter.cafe, Filter.restaurant, Filter.hospital, Filter.hotel, Filter.notUsed]
            }
        }
    }
    
    enum Filter{
        case all, friends, notUsed, complete, new,
             hospital, cafe, restaurant, hotel, shop
        
        var isActive:Bool {
            switch self {
            case .notUsed: return false
            default : return true
            }
        }
        var icon:String{
            switch self {
            case .hospital: return Asset.map.pinHospital
            case .cafe: return Asset.map.pinCafe
            case .restaurant: return Asset.map.pinRestaurant
            case .hotel: return Asset.map.pinHotel
            case .shop: return Asset.map.pinSalon
            default : return ""
            }
        }
        func getTitle(type:SortType)->String{
            switch self {
            case .all: return type.title
            case .complete: return String.sort.complete
            case .new: return String.sort.new
            case .friends: return String.sort.friends
            case .notUsed: return type.title
            case .hospital: return String.sort.hospital
            case .cafe: return String.sort.cafe
            case .restaurant: return String.sort.restaurant
            case .hotel: return String.sort.hotel
            case .shop: return String.sort.shop
            }
        }
        
        func getText(type:SortType)->String{
            switch self {
            case .all: return String.sort.all + " " + type.title
            case .complete: return String.sort.complete + " " + type.title
            case .new: return String.sort.new + " " + type.title
            case .friends: return String.sort.friendsText
            case .notUsed: return String.sort.notUsedText
            case .hospital: return String.sort.hospitalText
            case .cafe: return String.sort.cafeText
            case .restaurant: return String.sort.restaurantText
            case .hotel: return String.sort.hotelText
            case .shop: return String.sort.shopText
            }
        }
        
    }
}



class WalkManager:ObservableObject, PageProtocol{
    let locationObserver:LocationObserver
    private let dataProvider:DataProvider
    private var anyCancellable = Set<AnyCancellable>()
    private(set) var missions:[Mission] = []
    private(set) var missionUsers:[Mission] = []
    private(set) var places:[Place] = []
    private(set) var startTime:Date = Date()
    private(set) var startLocation:CLLocation? = nil
    private(set) var completedMissions:[Int] = []
    private(set) var completedWalk:Mission? = nil
    @Published var uiEvent:WalkUiEvent? = nil {didSet{ if uiEvent != nil { uiEvent = nil} }}
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
    @Published private (set) var playPoint:Int = 0
    @Published private (set) var playExp:Double = 0
    @Published private (set) var isSimpleView:Bool = false
    
    private (set) var userFilter:Filter = .all
    private (set) var placeFilter:Filter = .shop
    private (set) var missionFilter:Filter = .all
    
    init(
        dataProvider:DataProvider,
        locationObserver:LocationObserver){
        self.locationObserver = locationObserver
        self.dataProvider = dataProvider
    }
    
    func resetMapStatus(_ location:CLLocation, userFilter:Filter?=nil, placeFilter:Filter?=nil, missionFilter:Filter?=nil, isAll:Bool = false){
        if let filter = userFilter {
            self.userFilter = filter
            self.missionUsers = []
        }
        if let filter = placeFilter {
            self.placeFilter = filter
            self.places = []
        }
        if let filter = missionFilter {
            self.missionFilter = filter
            self.missions = []
        }
        if isAll {
            if self.currentMission == nil {
                self.missions = []
            }
            self.missionUsers = []
            self.places = []
            self.missions = []
        }
        self.event = .changeMapStatus
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
                self.resetMapStatus(location, isAll: true)
                return
            } else {
                DataLog.d("already updated", tag: self.tag)
                self.updateCheckAnotherStatus(location)
                return
            }
        }
        self.requestMapStatus(location)
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
        self.playExp = 0
        self.playPoint = 0
        self.completedMissions = []
        self.endMission()
        self.endTimer()
        self.event = .end
        self.status = .ready
        self.isSimpleView = false
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
        if distance < 20 {
            self.missionCompleted(mission)
            return
        }
        guard let waypoints = self.currentRoute?.waypoints else {return}
        guard let find = waypoints.firstIndex(where: {$0.distance(from: loc) < 5}) else {return}
        self.event = .findWaypoint(index: find, total:waypoints.count)
    }
    
    
    
    private func requestMapStatus(_ location:CLLocation){
        self.isMapLoading = true
        switch self.missionFilter {
        case .notUsed :
            self.event = .updatedMissions
            return
        default :
            self.dataProvider.requestData(q: .init(id: self.tag, type: .requestNewMission(location, distance: Self.distenceUnit), isOptional: true))
        }
        self.updateCheckAnotherStatus(location)
    }
    
    private func updateCheckAnotherStatus(_ location:CLLocation){
        if self.places.isEmpty {
            var searchKeyward:String? = nil
            switch self.placeFilter {
            case .restaurant : searchKeyward = "restaurant"
            case .cafe : searchKeyward = "cafe"
            case .hospital : searchKeyward = "hospital"
            case .notUsed :
                self.event = .updatedPlaces
                return
            default : break
            }
            self.dataProvider.requestData(q: .init(id: self.tag, type: .getPlace(location, distance: Self.distenceUnit, searchType: searchKeyward), isOptional: true))
        }
        if self.missionUsers.isEmpty {
            var searchType:MissionApi.SearchType = .User
            switch self.userFilter {
            case .friends : searchType = .Friend
            case .notUsed :
                self.event = .updatedUsers
                return
            default : break
            }
            self.dataProvider.requestData(q: .init(id: self.tag, type: .searchMission(.all, searchType, location: location, distance: Self.distenceUnit), isOptional: true))
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
                let missions = datas.map{Mission().setData($0, type: .new)}
                switch self.missionFilter {
                case .new : self.missions = missions.filter{!$0.isCompleted}
                case .complete : self.missions = missions.filter{$0.isCompleted}
                default : self.missions = missions
                }
                self.event = .updatedMissions
            }
        case .searchMission :
            let me = self.dataProvider.user.snsUser?.snsID
            if let datas = res.data as? [MissionData] {
                self.missionUsers = datas.map{Mission().setData($0, type: .user)}.filter{$0.user?.currentProfile.userId != me}
                self.event = .updatedUsers
            }
        case .getPlace :
            let me = self.dataProvider.user.snsUser?.snsID ?? ""
            if let datas = res.data as? [PlaceData] {
                self.places = datas.map{Place().setData($0, me:me)}
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
