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
extension PlaceApi {
    enum PlaceCategoryType {
        case cafe, vet, park, none
        var icon:String{
            switch self {
            case .cafe: return Asset.map.pinCafe
            case .vet: return Asset.map.pinVet
            case .park: return Asset.map.pinPark
            default : return Asset.map.pinPark
            }
        }
                
        var iconMark:String{
            switch self {
            case .cafe: return Asset.map.pinCafeMark
            case .vet: return Asset.map.pinVetMark
            case .park: return Asset.map.pinParkMark
            default : return Asset.map.pinParkMark
            }
        }
                
        var color:Color{
            switch self {
            case .cafe: return Color.app.brown
            case .vet: return Color.app.greenDeep
            case .park: return Color.app.green
            default : return Color.app.green
            }
        }
        var title:String{
            switch self {
            case .cafe: return String.sort.cafe
            case .vet: return String.sort.vet
            case .park: return String.sort.park
            default : return ""
            }
        }
    
        
        static func getType(_ value:Int?) -> PlaceApi.PlaceCategoryType?{
            switch value{
            case 1 : return .cafe
            case 2 : return .park
            case 3 : return .vet
            default : return nil
            }
        }
    }
    
}

class PlaceApi :Rest{
    func get(location:CLLocation? = nil, distance:Double? = nil, searchType:String? = nil, zip:String? = nil,
             completion: @escaping (ApiItemResponse<PlaceData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["lat"] = location?.coordinate.latitude.description ?? ""
        params["lng"] = location?.coordinate.longitude.description ?? ""
        params["radius"] = distance?.toInt().description ?? ""
        if let searchType = searchType {
            params["searchType"] = searchType
            params["placeType"] = searchType.isEmpty ? "Place" : "Manual"
        } else {
            params["searchType"] = ""
            params["placeType"] = "Manual"
        }
        params["zipCode"] = zip ?? ""
        fetch(route: PlaceApiRoute (method: .get, action:.search, query: params), completion: completion, error:error)
    }
    
    func get(placeId:Int, page:Int?, size:Int?, completion: @escaping (ApiItemResponse<UserAndPet>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: PlaceApiRoute (method: .get, commandId: placeId.description, action:.visitors, query: params), completion: completion, error:error)
    }
    
    func post(place:Place? = nil, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["lat"] = place?.location?.coordinate.latitude.description ?? ""
        params["lng"] = place?.location?.coordinate.longitude.description ?? ""
        params["name"] = place?.title ?? ""
        params["googlePlaceId"] = place?.googlePlaceId ?? ""
        fetch(route: PlaceApiRoute (method: .post, action:.visit, body: params), completion: completion, error:error)
    }
}

struct PlaceApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "place"
    var commandId: String? = nil
    var action: ApiAction? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

