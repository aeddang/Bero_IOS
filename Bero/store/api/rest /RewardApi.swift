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

extension RewardApi {
    enum RewardType {
        case registPet, walk, mission, parkMission , visitPlace, requestFriend
        var icon : String {
            switch self {
            case .registPet : return Asset.icon.add
            case .walk: return Asset.icon.paw
            case .mission, .parkMission : return Asset.icon.goal
            case .visitPlace : return Asset.icon.arrived
            case .requestFriend : return Asset.icon.add_friend
            }
        }
        var text : String {
            switch self {
            case .registPet : return "Updated first dog profile"
            case .walk: return "Completed a walk"
            case .mission, .parkMission : return "Completed a mission"
            case .visitPlace : return "Left a mark"
            case .requestFriend : return "Request a friend"
            }
        }
        static func getType(_ value:String?) -> RewardApi.RewardType?{
            switch value{
            case "REGISTER_PET" : return .registPet
            case "WALK" : return .walk
            case "MISSION" : return .mission
            case "PARK_MISSION" : return .parkMission
            case "VISIT_PLACE" : return .visitPlace
            case "REQUEST_FRIEND" : return .requestFriend
            default : return nil
            }
        }
    }
    
    enum ValueType:String {
        case Exp, Point
    }
}

class RewardApi :Rest{
    func getHistory(userId:String, type:ValueType, page:Int?, size:Int?,  completion: @escaping (ApiItemResponse<RewardHistoryData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["userId"] = userId
        params["page"] = page?.description ?? "0"
        params["size"] = size?.description ?? ApiConst.pageSize.description
        params["rewardType"] = type.rawValue

        fetch(route: RewardApiRoute(action:.histories, query:params), completion: completion, error:error)
    }
}

struct RewardApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "rewards"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

