//
//  AlarmApiData.swift
//  Bero
//
//  Created by JeongCheol Kim on 2023/02/20.
//

import Foundation

struct AlarmData : Decodable {
    private(set) var alarmType: String? = nil
    private(set) var user: UserData? = nil
    private(set) var pet: PetData? = nil
    private(set) var album: PictureData? = nil
    private(set) var createdAt: String? = nil
}
