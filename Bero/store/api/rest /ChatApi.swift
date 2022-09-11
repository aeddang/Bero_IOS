//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

extension ChatApi {
    
}

class ChatApi :Rest{
    func get(page:Int?, size:Int?, completion: @escaping (ApiItemResponse<ChatData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: ChatRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func post(userId:String, contents:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["receiver"] = userId
        params["title"] = ""
        params["contents"] = contents
        fetch(route: ChatRoute(method: .post, action:.send, query: params), completion: completion, error:error)
    }
    
    func put(chatId:Int, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["ids"] = chatId.description
        fetch(route: ChatRoute(method: .put, action:.read, query: params), completion: completion, error:error)
    }
    
    func delete(chatId:Int, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["ids"] = chatId.description
        fetch(route: ChatRoute(method: .delete, query: params), completion: completion, error:error)
    }
    func deleteAll(chatIds:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["ids"] = chatIds
        fetch(route: ChatRoute(method: .delete, query: params), completion: completion, error:error)
    }
}

struct ChatRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "chats"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

