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
    func get(userId:String, page:Int?, size:Int?, completion: @escaping (ApiContentResponse<ChatsData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["otherUser"] = userId
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: ChatRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func get(roomId:Int, page:Int?, size:Int?, completion: @escaping (ApiContentResponse<ChatsData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: ChatRoomRoute (method: .get, action:.list, commandId: roomId.description, query: params), completion: completion, error:error)
    }
    
    func post(userId:String, contents:String, completion: @escaping (ApiContentResponse<ChatData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["receiver"] = userId
        params["title"] = ""
        params["contents"] = contents
        fetch(route: ChatRoute(method: .post, action:.send, query: params), completion: completion, error:error)
    }
    
    func delete(chatId:Int, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: ChatRoute(method: .delete, commandId:chatId.description), completion: completion, error:error)
    }
    
    func deleteAll(chatIds:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: ChatRoute(method: .delete, commandId:chatIds), completion: completion, error:error)
    }
    
    func getRoom( page:Int?, size:Int?, completion: @escaping (ApiItemResponse<ChatRoomData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        fetch(route: ChatRoomRoute (method: .get, query: params), completion: completion, error:error)
    }
    
    func putRoom(roomId:Int, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: ChatRoomRoute( method: .put, action:.read, commandId: roomId.description), completion: completion, error:error)
    }
    
    func deleteRoom(roomId:Int, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: ChatRoomRoute(method: .delete, commandId: roomId.description), completion: completion, error:error)
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

struct ChatRoomRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "chats/rooms"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var actionId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

