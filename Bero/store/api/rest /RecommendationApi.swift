//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI


class RecommendationApi :Rest{
    func get(action:ApiAction?, completion: @escaping (ApiItemResponse<UserAndPet>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: RecommendationRoute (method: .get, action:action), completion: completion, error:error)
    }
}

struct RecommendationRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "recommendation"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var actionId:String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

