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
    func get(user:SnsUser, completion: @escaping (ApiContentResponse<UserData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: UserApiRoute (method: .get, commandId: user.snsID), completion: completion, error:error)
    }
    
    func put(user:SnsUser, modifyData:ModifyUserProfileData, completion: @escaping (Blank) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: UserApiRoute(method: .put, commandId: user.snsID),
           constructingBlock:{ data in
            if let value = modifyData.nickName { data.append(value: value, name: "name") }
           
            if let value = modifyData.image?.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "profileImage.jpg",mimeType:"image/jpeg")
            }
        }, completion: completion, error:error)
    }
}

struct UserApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "users"
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
}

