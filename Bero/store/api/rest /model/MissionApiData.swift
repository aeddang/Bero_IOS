//
//  MissionApiData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/03.
//

import Foundation
struct MissionData : Decodable {
    private(set) var missionId: Int? = nil
    private(set) var missionCategory: String? = nil
    private(set) var missionType: String? = nil
    private(set) var difficulty: String? = nil
    private(set) var title: String? = nil
    private(set) var description: String? = nil
    private(set) var createdAt: String? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var duration: Double? = nil
    private(set) var distance: Double? = nil
    private(set) var point: Int? = nil
    private(set) var exp: Double? = nil
    private(set) var user: UserData? = nil
    private(set) var geos: [GeoData]? = nil
    private(set) var pets: [PetData]? = nil
    private(set) var place:MissionPlace? = nil
}

struct MissionPlace : Decodable {
    private(set) var geometry: GeometryData? = nil
    private(set) var icon: String? = nil
    private(set) var icon_background_color: String? = nil
    private(set) var name: String? = nil
    //private(set) var photos: String? = nil
    private(set) var place_id: String? = nil
    private(set) var scope: String? = nil
    private(set) var types: [String]? = nil
    private(set) var vicinity: String? = nil
}



