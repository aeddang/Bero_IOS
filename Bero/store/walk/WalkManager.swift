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
    case start, end, completed(Mission),
         startMission(Mission), endMission(Mission), completedMission(Mission),
         getRoute(Route), endRoute,
         changeMapStatus, updatedMissions, updatedPlaces , updatedUsers,
         findWaypoint(index:Int, total:Int), findPlace(Place)
    
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
    case moveMap(CLLocation), hiddenRoute
}
enum WalkError {
    case accessDenied, getRoute, updatedMissions
}
enum WalkStatus {
    case ready, walking
}
extension WalkManager {
    static var todayWalkCount:Int = 0
    static let distenceUnit:Double = 5000
    static let nearDistence:Double = 20
    static func viewSpeed(_ value:Double) -> String {
        return (value * 3600 / 1000).toTruncateDecimal(n:1) + String.app.kmPerH
    }
    static func viewDistance(_ value:Double) -> String {
        return (value / 1000).toTruncateDecimal(n:1) + String.app.km
    }
    static func viewDuration(_ value:Double) -> String {
        return value.secToMinString()
    }
    static func getPoint(_ value:Double) -> Int {
        return ceil(value/100).toInt() + 5//인증샷 점수
    }
    static func getExp(_ value:Double) -> Double {
        return ceil(value/100)
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
        // 현제 사용안함
        var filter:[Filter]{
            switch self {
            case .user: return [Filter.all, Filter.friends, Filter.notUsed]
            case .mission: return [Filter.all, Filter.complete, Filter.new, Filter.notUsed]
            case .place: return [Filter.petShop, Filter.cafe, Filter.restaurant, Filter.notUsed]
            }
        }
    }
    
    enum Filter{
        case all, friends, notUsed, complete, new,
             cafe, restaurant, petShop, vet
        
        static func getSortType(keyward:String)->Filter?{
            switch keyward {
            case "restaurant": return Filter.restaurant
            case "cafe": return Filter.cafe
            case "pet_store": return Filter.petShop
            case "hospital": return Filter.vet
            default : return nil
            }
        }
        
        var isActive:Bool {
            switch self {
            case .notUsed: return false
            default : return true
            }
        }
        var icon:String{
            switch self {
            case .cafe: return Asset.map.pinCafe
            case .restaurant: return Asset.map.pinRestaurant
            case .petShop: return Asset.map.pinSalon
            case .vet: return Asset.map.pinVet
            default : return ""
            }
        }
        var iconOn:String{
            switch self {
            case .cafe: return Asset.map.pinCafeOn
            case .restaurant: return Asset.map.pinRestaurantOn
            case .petShop: return Asset.map.pinSalonOn
            case .vet: return Asset.map.pinVetOn
            default : return ""
            }
        }
        var iconSort:String{
            switch self {
            case .cafe: return Asset.map.pinCafeIcon
            case .restaurant: return Asset.map.pinRestaurantIcon
            case .petShop: return Asset.map.pinSalonIcon
            case .vet: return Asset.map.pinVetIcon
            default : return ""
            }
        }
        var iconMark:String{
            switch self {
            case .cafe: return Asset.map.pinCafeMark
            case .restaurant: return Asset.map.pinRestaurantMark
            case .petShop: return Asset.map.pinSalonMark
            case .vet: return Asset.map.pinVetMark
            default : return ""
            }
        }
        var color:Color{
            switch self {
            case .cafe: return Color.app.brown
            case .restaurant: return Color.app.yellowDeep
            case .petShop: return Color.app.pink
            case .vet: return Color.app.greenDeep
            default : return Color.brand.primary
            }
        }
        
        var keyward:String{
            switch self {
            case .restaurant : return "restaurant"
            case .cafe : return "cafe"
            case .petShop : return "pet_store"
            case .vet : return "hospital"
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
            case .cafe: return String.sort.cafe
            case .restaurant: return String.sort.restaurant
            case .petShop: return String.sort.salon
            case .vet: return String.sort.vet
            }
        }
        
        func getText(type:SortType)->String{
            switch self {
            case .all: return String.sort.all + " " + type.title
            case .complete: return String.sort.complete + " " + type.title
            case .new: return String.sort.new + " " + type.title
            case .friends: return String.sort.friendsText
            case .notUsed: return String.sort.notUsedText
            case .cafe: return String.sort.cafeText
            case .restaurant: return String.sort.restaurantText
            case .petShop: return String.sort.salonText
            case .vet: return String.sort.vetText
            }
        }
        
    }
}

class WalkManager:ObservableObject, PageProtocol{
    let locationObserver:LocationObserver
    private var lockScreenManager:PageProtocol? = nil
    private let dataProvider:DataProvider
    private var anyCancellable = Set<AnyCancellable>()
    private(set) var missions:[Mission] = []
    private(set) var missionUsers:[Mission] = []
    private(set) var missionUsersSummary:[Mission] = []
    private(set) var places:[Place] = []
    private(set) var placesSummary:[Place] = []
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
    @Published private(set) var viewMission:Mission? = nil
    @Published private(set) var viewPlace:Place? = nil
    
    @Published private(set) var currentLocation:CLLocation? = nil
    @Published private(set) var isMapLoading:Bool = false
    @Published private(set) var currentDistenceFromMission:Double? = nil
    @Published private (set) var playPoint:Int = 0
    @Published private (set) var playExp:Double = 0
    @Published private (set) var isSimpleView:Bool = false
    
    private (set) var placeDatas:[String:[Place]] = [:]
    private (set) var userFilter:Filter = .all
    private (set) var placeFilters:[Filter] = [.vet, .restaurant, .cafe, .petShop]
    private (set) var missionFilter:Filter = .notUsed
    let nearDistence:Double = WalkManager.nearDistence
    let farDistence:Double = 10000
    var isBackGround:Bool = false
    init(
        dataProvider:DataProvider,
        locationObserver:LocationObserver){
            self.locationObserver = locationObserver
            self.dataProvider = dataProvider
            if #available(iOS 16.2, *) {
                self.lockScreenManager = LockScreenManager()
            }
    }
    
    func resetMapStatus(_ location:CLLocation? = nil, userFilter:Filter?=nil,  missionFilter:Filter?=nil, placeFilters:[Filter]?=nil, isAll:Bool = false){
        if let filter = userFilter {
            self.userFilter = filter
            self.missionUsers = []
            missionUsersSummary = []
        }
        if let filter = missionFilter {
            self.missionFilter = filter
            self.missions = []
        }
        if let filters = placeFilters {
            self.placeFilters = filters
            self.places = []
            self.placesSummary = []
        }
        if isAll {
            if self.currentMission == nil {
                self.missions = []
            }
            self.placeDatas = [:]
            self.missionUsers = []
            self.places = []
            self.missions = []
            self.missionUsersSummary = []
            self.placesSummary = []
        } 
        self.event = .changeMapStatus
        if let loc = location ?? self.currentLocation {
            self.updateMapStatus(loc)
        }
    }
    
    func resetMapFilter(_ location:CLLocation? = nil, placeFilter:Filter, use:Bool){
        if use && self.placeFilters.contains(placeFilter){
            return
        } else if !use && !self.placeFilters.contains(placeFilter) {
            return
        }
        if use {
            self.placeFilters.append(placeFilter)
        } else if let find = self.placeFilters.firstIndex(of: placeFilter) {
            self.placeFilters.remove(at: find)
        } else {
            return
        }
        if let loc = location ?? self.currentLocation {
            self.resetMapPlace(loc)
        }
        
    }
    
    func resetMapPlace(_ location:CLLocation, isAllShow:Bool = false){
        if isAllShow {
            self.placeFilters = [.vet, .restaurant, .cafe, .petShop]
        }
        self.places = []
        self.event = .changeMapStatus
        self.updateMapStatus(location)
    }
    
    func updateMapStatus(_ location:CLLocation){
        switch self.missionFilter {
        case .notUsed :
            DataLog.d("mission not used updated", tag: self.tag)
            self.updateCheckAnotherStatus(location)
        default :
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
            self.locationObserver.requestMe(false, id:self.tag, desiredAccuracy:.greatestFiniteMagnitude)
        }
    }
    
    func startWalk(){
        self.startTime = Date()
        self.startLocation = self.currentLocation
        self.event = .start
        self.status = .walking
        self.startTimer()
        if #available(iOS 16.2, *) , let lsm = self.lockScreenManager as? LockScreenManager {
            lsm.startLockScreen(data: .init(title: "start"))
        }
    }
    
    func completeWalk(){
        let mission = Mission().setData(self)
        self.completedWalk = mission
        self.event = .completed(mission)
    }
    
    func endWalk(){
        if #available(iOS 16.2, *) , let lsm = self.lockScreenManager as? LockScreenManager {
            lsm.endLockScreen(data: .init(title: "end", walkTime:self.walkTime , walkDistence:self.walkDistence))
        }
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
    
    func startMission(_ mission:Mission){
        self.currentMission = mission
        if let loc = self.currentLocation {
            mission.start(location: loc, walkDistence:self.walkDistence)
        }
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
        self.currentDistenceFromMission = nil
        self.event = .endMission(mission)
    }
    
    func forceCompleteMission(){
        guard let mission = self.currentMission else {return}
        self.missionCompleted(mission)
    }
    
    func registPlace(){
        self.filterPlace()
    }
    
    private func missionCompleted(_ mission:Mission){
        //self.currentMission = nil
        if mission.isCompleted {return}
        mission.completed(walkDistence: self.walkDistence)
        self.event = .completedMission(mission)
    }
    
    func viewRoute(mission:Mission){
        guard let goal = mission.destination else { return }
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
            self.walkDistence += diff
        }
        self.currentLocation = loc
        if self.isBackGround {
            if #available(iOS 16.2, *) , let lsm = self.lockScreenManager as? LockScreenManager {
                if let place = self.findPlace(loc) {
                    lsm.alertLockScreen(data: .init(
                        title: "FIND",
                        info: (place.name ?? "") + " find!",
                        walkTime: self.walkTime,
                        walkDistence: self.walkDistence))
                } else {
                    lsm.updateLockScreen(data: .init(walkTime: self.walkTime, walkDistence: self.walkDistence))
                }
            }

        } else {
            self.findPlace(loc)
        }
        /*
        guard let mission = self.currentMission else {return}
        guard let destination = mission.destination else {return}
        let distance = destination.distance(from: loc)
        self.currentDistenceFromMission = distance
        if distance < self.nearDistence {
            self.missionCompleted(mission)
        }
        */
        //self.findWayPoint(loc)
        
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
            self.placeFilters.forEach{ filter in
                let searchKeyward:String = filter.keyward
                if searchKeyward.isEmpty {return}
                if self.placeDatas[searchKeyward] == nil {
                    self.dataProvider.requestData(q: .init(id: self.tag, type: .getPlace(location, distance: Self.distenceUnit, searchType: searchKeyward), isOptional: true))
                }
            }
            self.checkOnReadyPlaceData()
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
            if let datas = res.data as? [MissionData] {
                self.filterUser(datas: datas)
            }
        case .getPlace(_, _ , let searchType) :
            if let datas = res.data as? [PlaceData], let key = searchType {
                let me = self.dataProvider.user.snsUser?.snsID ?? ""
                let placeDatas = datas.map{Place().setData($0, me:me, sortType: Filter.getSortType(keyward: key))}
                self.placeDatas[key] = placeDatas
                self.checkOnReadyPlaceData()
            }
        case .requestRoute :
            if let datas = res.data as? [MissionRoute] {
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
            self.viewRouteEnd()
            
        case .getPlace(_, _ , let searchType) :
            if let key = searchType {
                self.placeDatas[key] = []
                self.checkOnReadyPlaceData()
            }
        default : break
        }
    }
    
    private func filterUser(datas:[MissionData]){
        guard let loc = self.currentLocation else {
            DataLog.d("filterUser error notfound me", tag: self.tag)
            return
        }
        let me = self.dataProvider.user.snsUser?.snsID
        self.missionUsers = datas.map{Mission().setData($0, type: .user)}
            .filter{$0.user?.currentProfile.userId != me}
            .sorted(by: { p1, p2 in
                let distance1 = p1.destination?.distance(from: loc) ?? 0
                let distance2 = p2.destination?.distance(from: loc) ?? 0
                return distance1 < distance2
            })
            
        var summary:[Mission] = []
        var prev:Mission? = nil
        var idx:Int = 0
        for data in self.missionUsers {
            data.setRange(idx: idx, width: 0)
            idx += 1
            if let loc = data.destination {
                if let prevLoc = prev?.destination {
                    if prevLoc.distance(from: loc) < self.farDistence {
                        prev?.addCount()
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
        self.missionUsersSummary = summary
        self.event = .updatedUsers
    }
    
    private func findWayPoint(_ loc:CLLocation){
        /*
        guard let waypoints = self.currentRoute?.waypoints else {return}
        guard let find = waypoints.firstIndex(where: {$0.distance(from: loc) < self.nearDistence}) else {return}
        self.event = .findWaypoint(index: find, total:waypoints.count)
         */
    }
    
    private func checkOnReadyPlaceData(){
        let find = self.placeFilters.first(where: { filter in
            if filter.keyward.isEmpty {return false}
            return self.placeDatas[filter.keyward] == nil
        })
        if find == nil {
            self.filterPlace()
        }
    }
    
    private var finalFind:Place? = nil
    @discardableResult
    private func findPlace(_ loc:CLLocation)->Place?{
        guard let find = self.places.filter({!$0.isMark}).first(where: {$0.location!.distance(from: loc) < self.nearDistence}) else {
            //DataLog.d("findPlace not find", tag: self.tag)
            self.finalFind = nil
            return nil
        }
        if self.finalFind != nil {
            DataLog.d("findPlace already find", tag: self.tag)
            return nil
        }
        self.finalFind = find
        DataLog.d("findPlace find " + (find.name ?? ""), tag: self.tag)
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
        let datas:[Place] = self.placeFilters.reduce(initDatas, { prev, filter in
            var addDatas:[Place] = self.placeDatas[filter.keyward] ?? []
            addDatas.shuffle()
            var add:[Place] = Array(addDatas.prefix(10))
            add.append(contentsOf: prev)
            return add
        })
        .sorted(by: { p1, p2 in
            let distance1 = p1.location?.distance(from: loc) ?? 0
            let distance2 = p2.location?.distance(from: loc) ?? 0
            return distance1 < distance2
        })
        
        var count:Int = 0
        let completed = datas.filter{$0.isMark}
        let new = datas.filter{!$0.isMark}
        var fixed:[Place] = []
        let limited = self.nearDistence*5
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
        for data in datas {
            if let loc = data.location {
                if let prevLoc = prev?.location {
                    if prevLoc.distance(from: loc) < self.farDistence {
                        prev?.addCount()
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
        self.placesSummary = summary
        self.event = .updatedPlaces
    }
}
