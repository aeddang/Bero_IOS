//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI
import CoreLocation

extension MiscApi {
    enum Category:String {
        case breed, status, personality, height, interest
        
        var apiCoreKey: String{
            return "Status" + self.rawValue
        }
    }
    
    enum ReportType:String {
        case mission, user, post, chat
        var apiCoreKey : String {
            switch self {
            case .mission : return "MISSION"
            case .user : return "USER"
            case .post : return "POST"
            case .chat : return "CHAT"
            }
        }
        var completeMessage : String {
            switch self {
            case .post : return String.alert.accuseAlbumCompleted
            default : return String.alert.accuseUserCompleted
            }
        }
        
    }
    
    enum AlarmType:String {
        case User, Album, Friend, Chat
        
        static func getType(_ value:String?) -> AlarmType?{
            switch value{
            case "User" : return .User
            case "Album" : return .Album
            case "Friend" : return .Friend
            case "Chat" : return .Chat
            default : return nil
            }
        }
    }
}

class MiscApi :Rest{
    func getWeather(location:CLLocation, completion: @escaping (ApiContentResponse<WeatherCityData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["lat"] = location.coordinate.latitude.description
        params["lng"] = location.coordinate.longitude.description
        
        fetch(route: WeatherApiRoute(query:params), completion: completion, error:error)
    }
    func getWeather(id:String, action:ApiAction = .cities, completion: @escaping (ApiContentResponse<WeatherCityData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: WeatherApiRoute(action:action, commandId: id), completion: completion, error:error)
    }
    
    func getBanner(id:String, dateValue:String?, completion: @escaping (ApiContentResponse<BannerData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["exposedDate"] = dateValue ?? ""
        fetch(route: BannerApiRoute(commandId: id, query:params), completion: completion, error:error)
    }
    
    func getCode(category:MiscApi.Category, searchKeyword:String? = nil, completion: @escaping (ApiItemResponse<CodeData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["category"] = category.rawValue
        params["searchText"] = searchKeyword ?? ""
        fetch(route: CodeApiRoute(query:params), completion: completion, error:error)
    }
    
    func postReport(type:MiscApi.ReportType, postId:String? = nil, userId : String? = nil, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["reportType"] = type.apiCoreKey
        params["postId"] = postId
        params["refUserId"] = userId
        fetch(route: ReportApiRoute(method:.post, body:params), completion: completion, error:error)
    }
    
    func getAlarm( page:Int?, size:Int?, completion: @escaping (ApiItemResponse<AlarmData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: AlarmApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    
}

struct WeatherApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "misc/weather"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

struct CodeApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "misc/codes"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

struct ReportApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "misc/report/things"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

struct BannerApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "misc/banners"
    var commandId: String? = nil
    var query:[String: String]? = nil
}

struct AlarmApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "misc/alarms"
    var query:[String: String]? = nil
}

