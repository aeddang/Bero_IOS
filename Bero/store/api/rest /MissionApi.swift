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
            case .all : return Asset.icon.paw
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
        case Distance, Time, Random, User, Walk, Friend
        var title : String {
            switch self {
            case .User, .Random: return String.sort.all
            case .Friend : return String.sort.friends
            default : return ""
            }
        }
        var text : String {
            switch self {
            case .User, .Random : return String.sort.all + " " + String.app.users.lowercased()
            case .Friend : return String.sort.friendsText
            default : return ""
            }
        }
    }
}

class MissionApi :Rest{
    func get(userId:String?, petId:Int?, date:Date?, cate:MissionApi.Category, page:Int?, size:Int?,
             completion: @escaping (ApiItemResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["userId"] = userId ?? ""
        params["petId"] = petId?.description ?? ""
        params["missionCategory"] = cate.getApiCode
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        if let date = date { params["date"] = date.toDateFormatter(dateFormat: "yyyy-MM-dd") }
        fetch(route: MissionApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func get(cate:MissionApi.Category, search:MissionApi.SearchType, searchValue:String? = nil, location:CLLocation? = nil,distance:Double? = nil, page:Int?, size:Int?,
             completion: @escaping (ApiItemResponse<MissionData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["searchType"] = search.rawValue
        params["searchValue"] = searchValue
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
        params["exp"] = mission.exp
        params["pictureUrl"] = pictureUrl
        params["petIds"] = pets.map{$0.petId}
        params["placeId"] = mission.place?.place_id
        var geos: [[String: Any]] = []
        if let loc = mission.departure {
            var geo :[String: Any] = [:]
            geo["lat"] = loc.coordinate.latitude
            geo["lng"] = loc.coordinate.longitude
            geos.append(geo)
        }
        if let loc = mission.location {
            var geo :[String: Any] = [:]
            geo["lat"] = loc.coordinate.latitude
            geo["lng"] = loc.coordinate.longitude
            geos.append(geo)
        }
        params["geos"] = geos
        params["missionIds"] =  mission.completedMissions
        fetch(route: MissionApiRoute (method: .post, body: params), completion: completion, error:error)
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

