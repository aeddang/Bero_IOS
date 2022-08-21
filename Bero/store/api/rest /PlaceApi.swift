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


class PlaceApi :Rest{
    func get(location:CLLocation? = nil, distance:Double? = nil, searchType:String? = nil, completion: @escaping (ApiItemResponse<PlaceData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["lat"] = location?.coordinate.latitude.description ?? ""
        params["lng"] = location?.coordinate.longitude.description ?? ""
        params["radius"] = distance?.toInt().description ?? ""
        params["searchType"] = searchType ?? "pet_store"
        fetch(route: PlaceApiRoute (method: .get, action:.search, query: params), completion: completion, error:error)
    }
    
    func post(place:Place? = nil, completion: @escaping (Blank) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["lat"] = place?.location?.coordinate.latitude.description ?? ""
        params["lng"] = place?.location?.coordinate.longitude.description ?? ""
        params["name"] = place?.name ?? ""
        params["googlePlaceId"] = place?.googlePlaceId ?? ""
        fetch(route: PlaceApiRoute (method: .post, action:.visit, body: params), completion: completion, error:error)
    }
}

struct PlaceApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "place"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

