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

extension WalkApi {
    enum Status:String {
        case Walking, Finish
    }
}


struct WalkadditionalData{
    var img:UIImage? = nil
    var thumbImg:UIImage? = nil
    var walkTime:Double? = nil
    var walkDistance:Double? = nil
}

class WalkApi :Rest{
    func get(id:Int?,
             completion: @escaping (ApiContentResponse<WalkData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        //var params = [String: String]()
        //params["pictureType"] = type.getApiCode()
        //params["page"] = page?.description ?? "0"
        //params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: WalkApiRoute (method: .get, commandId: id?.description), completion: completion, error:error)
    }
    
    func get(date:Date?,
             completion: @escaping (ApiItemResponse<WalkData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        if let date = date { params["date"] = date.toDateFormatter(dateFormat: "yyyy-MM-dd") }
        params["size"] = "999"
        fetch(route: WalkApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func get(userId:String?, page:Int?, size:Int?,
             completion: @escaping (ApiItemResponse<WalkData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["userId"] = userId ?? ""
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: WalkApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func get(loc:CLLocation, radius:Int, min:Int, page:Int?, size:Int?,
             completion: @escaping (ApiItemResponse<WalkUserData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["lat"] = loc.coordinate.latitude.description
        params["lng"] = loc.coordinate.longitude.description
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        params["radius"] = radius.description
        params["latestWalkMin"] = min.description
        fetch(route: WalkApiRoute (method: .get, action: .search, query: params), completion: completion, error:error)
    }
    
    func getFriend(page:Int?, size:Int?,
             completion: @escaping (ApiItemResponse<WalkUserData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description

        fetch(route: WalkApiRoute (method: .get, action: .search, actionId: "friends", query: params), completion: completion, error:error)
    }
    
    func post(loc:CLLocation, pets:[PetProfile],
              completion: @escaping (ApiContentResponse<WalkRegistData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["petIds"] = pets.map{$0.petId}
        var geo :[String: Any] = [:]
        geo["lat"] = loc.coordinate.latitude
        geo["lng"] = loc.coordinate.longitude
        params["location"] = geo
        fetch(route: WalkApiRoute (method: .post, body: params), completion: completion, error:error)
    }
    
    func put(id:Int, loc:CLLocation, status:WalkApi.Status, additionalData:WalkadditionalData? = nil,
             completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        fetch(route: WalkApiRoute(method: .put, commandId: id.description), constructingBlock:{ data in
            data.append(value: loc.coordinate.latitude.description, name: "lat")
            data.append(value: loc.coordinate.longitude.description, name: "lng")
            data.append(value: status.rawValue, name: "status")
            if let value = additionalData?.walkTime?.toInt() {
                data.append(value: value.description, name: "duration")
            }
            if let value = additionalData?.walkDistance?.toInt() {
                data.append(value: value.description, name: "distance")
            }
            /*
            if let value = additionalData?.img?.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "albumImage.jpg",mimeType:"image/jpeg")
            }*/
            if let value = additionalData?.img?.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "albumImage.jpg",mimeType:"image/jpeg")
            }
            if let value = additionalData?.thumbImg?.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "smallContents",fileName: "thumbAlbumImage.jpg",mimeType:"image/jpeg")
            }
        }, completion: completion, error:error)
    }
    
    func get(departure:CLLocation,destination:CLLocation,
             completion: @escaping (ApiItemResponse<WalkRoute>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["originLat"] = departure.coordinate.latitude.description
        params["originLng"] = departure.coordinate.longitude.description
        params["destLat"] = destination.coordinate.latitude.description
        params["destLng"] = destination.coordinate.longitude.description
        fetch(route: WalkApiRoute (method: .get, action:.directions, query: params), completion: completion, error:error)
    }

    func getMonthly(userId:String, date:Date,
             completion: @escaping (ApiItemResponse<String>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["userId"] = userId
        params["month"] = date.toDateFormatter(dateFormat: "yyyy-MM")
        fetch(route: WalkApiRoute (method: .get, action:.monthlyList, query: params), completion: completion, error:error)
    }
    func getSummary(petId:Int?,
             completion: @escaping (ApiContentResponse<WalkSummary>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["petId"] = petId?.description ?? ""
        fetch(route: WalkApiRoute (method: .get, action:.summary, query: params), completion: completion, error:error)
    }
}

struct WalkApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "walk"
    var commandId: String? = nil
    var action: ApiAction? = nil
    var actionId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}
