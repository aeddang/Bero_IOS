//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

extension FriendApi {
    
}

class FriendApi :Rest{
    func get(userId:String? = nil, action:ApiAction?, page:Int?, size:Int?, completion: @escaping (ApiItemResponse<FriendData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: FriendRoute (method: .get, action:action, actionId: userId, query: params), completion: completion, error:error)
    }
    
    func post(userId:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["otherUserId"] = userId
        fetch(route: FriendRoute(method: .post, action:.request, query: params), completion: completion, error:error)
    }
    
    func put(action:ApiAction?, userId:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["otherUserId"] = userId
        fetch(route: FriendRoute(method: .put, action:action, query: params), completion: completion, error:error)
    }
    
    func delete(userId:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["otherUserId"] = userId
        fetch(route: FriendRoute(method: .delete, query: params), completion: completion, error:error)
    }
}

struct FriendRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "friends"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var actionId:String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

