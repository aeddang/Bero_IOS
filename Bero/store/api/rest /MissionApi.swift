//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import CoreLocation
import GoogleMaps

class Walk{
    var locations:[CLLocation] = []
    var playTime:Double = 0
    var playDistence:Double = 0
    var pictureUrl:String? = nil
    func point()->Double {
        return 10 + floor(playDistence/1000)*10
    }
}


extension MissionApi {
    enum Category {
        case walk, mission, all
        var getApiCode : String {
            switch self {
            case .walk : return "Walk"
            case .mission : return "Mission"
            case .all : return "All"
            }
        }
        
        var text : String {
            switch self {
            case .walk : return "Walk"
            case .mission : return "Mission"
            case .all : return ""
            }
        }
        var icon : String {
            switch self {
            case .walk : return Asset.icon.paw
            case .mission : return Asset.icon.goal
            case .all : return ""
            }
        }
        static func getCategory(_ value:String?) -> MissionApi.Category?{
            switch value{
            case "Walk" : return .walk
            case "Mission" : return .mission
            default : return nil
            }
        }
    }
    
    enum SearchType:String {
        case Distance, Time, Random, User
    }
}

class MissionApi :Rest{
    func get(userId:String?, petId:Int?, cate:MissionApi.Category, page:Int?, size:Int?,
             completion: @escaping (ApiItemResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["userId"] = userId ?? ""
        params["petId"] = petId?.description ?? ""
        params["missionCategory"] = cate.getApiCode
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: MissionApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func get(cate:MissionApi.Category, search:MissionApi.SearchType, location:CLLocation? = nil,distance:Double? = nil, page:Int?, size:Int?,
             completion: @escaping (ApiItemResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["searchType"] = search.rawValue
        params["radius"] = distance?.toInt().description ?? ""
        params["lat"] = location?.coordinate.latitude.description ?? ""
        params["lng"] = location?.coordinate.longitude.description ?? ""
        params["missionCategory"] = cate.getApiCode
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: MissionApiRoute (method: .get, action:.search, query: params), completion: completion, error:error)
    }
    
    func get(location:CLLocation? = nil,distance:Double? = nil,
             completion: @escaping (ApiItemResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["distance"] = distance?.toInt().description ?? ""
        params["lat"] = location?.coordinate.latitude.description ?? ""
        params["lng"] = location?.coordinate.longitude.description ?? ""
        fetch(route: MissionApiRoute (method: .get, action:.newMissions, query: params), completion: completion, error:error)
    }
    
    
    func get(departure:CLLocation,destination:CLLocation,
             completion: @escaping (ApiItemResponse<MissionRoute>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["originLat"] = departure.coordinate.latitude.description
        params["originLng"] = departure.coordinate.longitude.description
        params["destLat"] = destination.coordinate.latitude.description
        params["destLng"] = destination.coordinate.longitude.description
        fetch(route: MissionApiRoute (method: .get, action:.directions, query: params), completion: completion, error:error)
    }
    
    func post(mission:Mission, pets:[PetProfile] , pictureUrl:String?,  completion: @escaping (ApiContentResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["missionCategory"] = mission.type.apiDataKey
        switch mission.type {
        case .walk : break
        default :
            params["title"] = mission.title
            params["description"] = mission.description
            params["difficulty"] = mission.difficulty
           
        }
        params["duration"] = mission.duration
        params["distance"] = mission.distance
        params["point"] = mission.point
        params["pictureUrl"] = pictureUrl
        params["petIds"] = pets.map{$0.petId}
        var geos: [[String: Any]] = []
        if let loc = mission.departure {
            var geo :[String: Any] = [:]
            geo["lat"] = loc.coordinate.latitude
            geo["lng"] = loc.coordinate.longitude
            geos.append(geo)
        }
        if let loc = mission.destination {
            var geo :[String: Any] = [:]
            geo["lat"] = loc.coordinate.latitude
            geo["lng"] = loc.coordinate.longitude
            geos.append(geo)
        }
        params["geos"] = geos
        fetch(route: MissionApiRoute (method: .post, body: params), completion: completion, error:error)
    }
    
    
    func post(walk:Walk, pets:[PetProfile] , completion: @escaping (ApiContentResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["missionCategory"] = Category.walk.getApiCode
       
        params["duration"] = walk.playTime
        params["distance"] = walk.playDistence
        params["pictureUrl"] = walk.pictureUrl
        let point = walk.point()
        params["point"] = point
        params["experience"] = point
        params["petIds"] = pets.map{$0.petId}
        
        let geos: [[String: Any]] = walk.locations.map{
            var geo = [String: Any]()
            geo["lat"] = $0.coordinate.latitude
            geo["lng"] = $0.coordinate.longitude
            return geo
        }
        params["geos"] = geos
        fetch(route: MissionApiRoute (method: .post, body: params), completion: completion, error:error)
    }
    
    
    func getSummary(petId:Int?,
             completion: @escaping (ApiContentResponse<MissionSummary>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["petId"] = petId?.description ?? ""
        fetch(route: MissionApiRoute (method: .get, action:.summary, query: params), completion: completion, error:error)
    }
}

struct MissionApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "missions"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

