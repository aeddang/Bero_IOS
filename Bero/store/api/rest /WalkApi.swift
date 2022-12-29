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
    
}

class WalkApi :Rest{
    func get(id:Int?, completion: @escaping (ApiItemResponse<WalkData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        //var params = [String: String]()
        //params["pictureType"] = type.getApiCode()
        //params["page"] = page?.description ?? "0"
        //params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: WalkApiRoute (method: .get, commandId: id?.description), completion: completion, error:error)
    }
    
    func post(loc:CLLocation, pets:[PetProfile], completion: @escaping (ApiContentResponse<WalkRegistData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["petIds"] = pets.map{$0.petId}
        var geo :[String: Any] = [:]
        geo["lat"] = loc.coordinate.latitude
        geo["lng"] = loc.coordinate.longitude
        params["location"] = geo
        fetch(route: WalkApiRoute (method: .post, body: params), completion: completion, error:error)
    }
    
    func put(id:Int, loc:CLLocation, img:UIImage?, thumbImg:UIImage?, completion: @escaping (ApiItemResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: WalkApiRoute(method: .put, commandId: id.description),
           constructingBlock:{ data in
            data.append(value: loc.coordinate.latitude.description, name: "lat")
            data.append(value: loc.coordinate.longitude.description, name: " lng")
            //data.append(value: loc.coordinate.latitude.description, name: "estimate")
            //data.append(value: loc.coordinate.latitude.description, name: "status")
            if let value = img?.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "albumImage.jpg",mimeType:"image/jpeg")
            }
            if let value = thumbImg?.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "smallContents",fileName: "thumbAlbumImage.jpg",mimeType:"image/jpeg")
            }
        }, completion: completion, error:error)
    }
}

struct WalkApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "walk"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

