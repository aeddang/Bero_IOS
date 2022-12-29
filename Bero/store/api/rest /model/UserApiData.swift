//
//  UserData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/12/05.
//

import Foundation

struct UserData : Decodable {
    private(set) var userId: String? = nil
    private(set) var refUserId: String? = nil
    private(set) var password: String? = nil
    private(set) var name: String? = nil
    private(set) var email: String? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var providerType: String? = nil
    private(set) var roleType: String? = nil
    
    private(set) var point: Int? = nil
    private(set) var birthdate: String? = nil
    private(set) var sex: String? = nil
    private(set) var introduce: String? = nil
    private(set) var exp:Double? = nil
    private(set) var exerciseDuration: Double? = nil
    private(set) var walkDistance: Double? = nil
    private(set) var missionDistance: Double? = nil
    private(set) var walkCompleteCnt: Int? = nil
    private(set) var missionCompleteCnt: Int? = nil
    private(set) var level: Int? = nil
    private(set) var isChecked: Bool? = nil
    private(set) var isFriend: Bool? = nil
    private(set) var createdAt: String? = nil
    
    private(set) var nextLevelExp: Double? = nil
    private(set) var prevLevelExp: Double? = nil
}
