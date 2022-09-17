//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit

class UserApi :Rest{
    func post(pushToken:String, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: Any]()
        params["deviceId"] = SystemEnvironment.deviceId
        params["token"] = pushToken
        params["platform"] = "IOS"
        fetch(route: UserApiRoute (method: .post, action: .pushToken, body: params), completion: completion, error:error)
    }
    func get(user:SnsUser, completion: @escaping (ApiContentResponse<UserData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: UserApiRoute (method: .get, commandId: user.snsID), completion: completion, error:error)
    }
    func get(userId:String, completion: @escaping (ApiContentResponse<UserData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: UserApiRoute (method: .get, commandId: userId), completion: completion, error:error)
    }
    func put(user:SnsUser, modifyData:ModifyUserProfileData, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: UserApiRoute(method: .put, commandId: user.snsID),
           constructingBlock:{ data in
            if let value = modifyData.nickName { data.append(value: value, name: "name") }
            if let value = modifyData.birth?.toDateFormatter() { data.append(value: value.subString(start: 0, len: 19), name: "birthdate") }
            if let value = modifyData.gender?.apiDataKey { data.append(value: value, name: "sex") }
            if let value = modifyData.introduction { data.append(value: value, name: " introduce") }

            if let value = modifyData.image?.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "profileImage.jpg",mimeType:"image/jpeg")
            }
        }, completion: completion, error:error)
    }
    func put(user:SnsUser, image:UIImage?, completion: @escaping (ApiContentResponse<Blank>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: UserApiRoute(method: .put, commandId: user.snsID),
           constructingBlock:{ data in
            if let value = image?.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "profileImage.jpg",mimeType:"image/jpeg")
            } else {
                data.append(file: Data(),name: "contents",fileName: "profileImage.jpg",mimeType:"image/jpeg")
            }
            data.log()
        }, completion: completion, error:error)
    }
}

struct UserApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "users"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
}

