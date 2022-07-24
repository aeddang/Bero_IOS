//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation

class AuthApi :Rest{
    func post(user:SnsUser, info:SnsUserInfo? = nil, completion: @escaping (ApiContentResponse<UserAuth>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["providerType"] = user.snsType.apiCode()
        params["id"] = user.snsID
        params["password"] = user.snsToken
        params["name"] = info?.nickName
        params["email"] = info?.email
        fetch(route: AuthApiRoute (method: .post, body: params), completion: completion, error:error)
    }
    
    func reflash(user:SnsUser, completion: @escaping (ApiContentResponse<UserAuth>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["providerType"] = "Token"
        params["id"] = user.snsID
        params["password"] = ApiNetwork.accesstoken
        ApiNetwork.reset()
        fetch(route: AuthApiRoute (method: .post, body: params), completion: completion, error:error)
    }
}

struct AuthApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "auth/login"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

