//
//  WalkApiData.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/12/22.
//

import Foundation
struct WalkData : Decodable {
    private(set) var walkId: Int? = nil
    private(set) var createdAt: String? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var duration: Double? = nil
    private(set) var distance: Double? = nil
    private(set) var point: Int? = nil
    private(set) var exp: Double? = nil
    private(set) var user: UserData? = nil
    private(set) var geos: [GeoData]? = nil
    private(set) var pets: [PetData]? = nil
}

struct WalkRegistData : Decodable {
    private(set) var walkId: Int? = nil
}
