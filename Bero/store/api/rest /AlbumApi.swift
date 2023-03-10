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
        case pet, user, mission, all
        func getApiCode() -> String {
            switch self {
            case .pet : return "Pet"
            case .user : return "User"
            case .mission : return "Mission"
            case .all : return "All"
            }
        }
        
        static func getCategory(_ value:String?) -> AlbumApi.Category?{
            switch value{
            case "Pet" : return .pet
            case "User" : return .user
            case "Mission" : return .mission
            default : return nil
            }
        }
        
        static func ==(lhs: Category, rhs: Category) -> Bool {
            switch (lhs, rhs) {
            case ( .user, .user):return true
            case ( .pet, .pet):return true
            case ( .mission, .mission):return true
            default: return false
            }
        }
    }
    
    enum SearchType:Equatable {
        case friends, all
        func getApiCode() -> String {
            switch self {
            case .friends : return "Friends"
            case .all : return ""
            }
        }
        var title : String {
            switch self {
            case .all: return String.sort.all
            case .friends : return String.sort.friends
            }
        }
        var text : String {
            switch self {
            case .all : return String.sort.all + " " + String.app.users.lowercased()
            case .friends : return String.sort.friendsText
            }
        }
    }
    
    public static let originSize:CGFloat = 320
    public static let thumbSize:CGFloat = 120
       
}

class AlbumApi :Rest{
    func get(id:String?, referenceId:String?, type:AlbumApi.Category, searchType:AlbumApi.SearchType, isExpose:Bool? = nil, page:Int?, size:Int?, completion: @escaping (ApiItemResponse<PictureData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["pictureType"] = type.getApiCode()
        params["searchType"] = searchType.getApiCode()
        if let id = id {
            params["ownerId"] = id
        }
        if let id = referenceId {
            params["referenceId"] = id
        }
        if let isExpose = isExpose {
            params["isExpose"] = isExpose ? "1" : "0"
        }
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: AlbumPicturesApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func post(img:UIImage,thumbImg:UIImage, id:String, type:AlbumApi.Category, isExpose:Bool?, referenceId:String?, completion: @escaping (ApiContentResponse<PictureData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: AlbumPicturesApiRoute(method: .post),
           constructingBlock:{ data in
            data.append(value: type.getApiCode(), name: "pictureType")
            data.append(value: id, name: "ownerId")
            if let isExpose = isExpose {
                data.append(value: isExpose.description, name: "isExpose")
            }
            if let value = referenceId {
                data.append(value: value, name: "referenceId")
            }
            if let value = img.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "albumImage.jpg",mimeType:"image/jpeg")
            }
            if let value = thumbImg.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "smallContents",fileName: "thumbAlbumImage.jpg",mimeType:"image/jpeg")
            }
        }, completion: completion, error:error)
    }
    
    func put( id:Int, isLike:Bool?, isExpose:Bool?, completion: @escaping (ApiItemResponse<PictureUpdateData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var param = [String: Any]()
        param["id"] = id
        var action:ApiAction? = nil
        if let isLike = isLike {
            param["isChecked"] = isLike
            action = .thumbsup
        }
        if let isExpose = isExpose {
            param["isExpose"] = isExpose
        }
        var params = [String: Any]()
        params["items"] = [param]
        fetch(route: AlbumPicturesApiRoute(method: .put, action:action, body:params), completion: completion, error:error)
    }
    
    
    func delete(ids:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
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

