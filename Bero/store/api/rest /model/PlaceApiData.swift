//
//  PlaceApiData.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/19.
//

import Foundation
struct PlaceData : Decodable {
    private(set) var placeId: Int? = nil
    private(set) var location: String? = nil
    private(set) var name: String? = nil
    private(set) var googlePlaceId: String? = nil
    private(set) var createdAt: String? = nil
    private(set) var visitors: [PlaceVisitor]? = nil
    private(set) var place:MissionPlace? = nil
}
struct PlaceVisitor : Decodable {
    private(set) var user: UserData? = nil
    private(set) var pet: PetData? = nil
}

