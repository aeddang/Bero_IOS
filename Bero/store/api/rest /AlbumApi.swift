//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

extension AlbumApi {
    enum Category:Equatable {
        case pet, user
        func getApiCode() -> String {
            switch self {
            case .pet : return "Pet"
            case .user : return "User"
            }
        }
        
        static func getCategory(_ value:String?) -> AlbumApi.Category?{
            switch value{
            case "Pet" : return .pet
            case "User" : return .user
            default : return nil
            }
        }
        
        static func ==(lhs: Category, rhs: Category) -> Bool {
            switch (lhs, rhs) {
            case ( .user, .user):return true
            case ( .pet, .pet):return true
            default: return false
            }
        }
    }
}

class AlbumApi :Rest{
    func get(id:String, type:AlbumApi.Category,  page:Int?, size:Int?, completion: @escaping (ApiItemResponse<PictureData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["pictureType"] = type.getApiCode()
        params["ownerId"] = id
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: AlbumPicturesApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func post(img:UIImage,thumbImg:UIImage, id:String, type:AlbumApi.Category, completion: @escaping (ApiContentResponse<PictureData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: AlbumPicturesApiRoute(method: .post),
           constructingBlock:{ data in
            data.append(value: type.getApiCode(), name: "pictureType")
            data.append(value: id, name: "ownerId")
            if let value = img.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "albumImage.jpg",mimeType:"image/jpeg")
            }
            if let value = thumbImg.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "smallContents",fileName: "thumbAlbumImage.jpg",mimeType:"image/jpeg")
            }
        }, completion: completion, error:error)
    }
    
    func put( id:Int, isLike:Bool, completion: @escaping (ApiItemResponse<PictureUpdateData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var param = [String: Any]()
        param["id"] = id
        param["isChecked"] = isLike
        
        var params = [String: Any]()
        params["items"] = [param]
        fetch(route: AlbumPicturesApiRoute(method: .put, action:.thumbsup, body:params), completion: completion, error:error)
    }
    
    
    func delete(ids:String, completion: @escaping (Blank) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["pictureIds"] = ids
        fetch(route: AlbumPicturesApiRoute(method: .delete, query: params), completion: completion, error:error)
    }
}

struct AlbumPicturesApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "album/pictures"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

