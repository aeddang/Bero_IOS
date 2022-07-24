//
//  UserData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/12/05.
//

import Foundation

struct UserData : Decodable {
    private(set) var userId: String? = nil
    private(set) var password: String? = nil
    private(set) var name: String? = nil
    private(set) var email: String? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var providerType: String? = nil
    private(set) var roleType: String? = nil
    private(set) var exerciseDuration: Double? = nil
    private(set) var point: Int? = nil
}
