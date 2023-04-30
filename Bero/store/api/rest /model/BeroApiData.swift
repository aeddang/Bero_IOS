//
//  BeroApiData.swift
//  Bero
//
//  Created by JeongCheol Kim on 2023/02/12.
//

import Foundation

struct UserAndPet: Decodable {
    private(set) var user: UserData? = nil
    private(set) var pet: PetData? = nil
}

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
    private(set) var exerciseDistance: Double? = nil
    private(set) var exerciseDuration: Double? = nil
    private(set) var walkCompleteCnt: Int? = nil
    private(set) var level: Int? = nil
    private(set) var isChecked: Bool? = nil
    private(set) var isFriend: Bool? = nil
    private(set) var createdAt: String? = nil
    
    private(set) var nextLevelExp: Double? = nil
    private(set) var prevLevelExp: Double? = nil
}

struct PetData : Decodable {
    private(set) var petId: Int? = nil
    private(set) var name: String? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var birthdate: String? = nil
    private(set) var sex: String? = nil
    private(set) var regNumber: String? = nil
    private(set) var animalId: String? = nil
    private(set) var status: String? = nil
    private(set) var exerciseDistance: Double? = nil
    private(set) var exerciseDuration: Double? = nil
    private(set) var weight: Double? = nil
    private(set) var size: Double? = nil
    private(set) var walkCompleteCnt: Int? = nil
    private(set) var thumbsupCount: Int? = nil
    private(set) var isChecked: Bool? = nil
    private(set) var tagStatus: String? = nil
    private(set) var tagPersonality: String? = nil
    private(set) var tagHeight: String? = nil
    private(set) var tagInterest: String? = nil
    private(set) var tagBreed: String? = nil
    private(set) var introduce: String? = nil
    private(set) var userId:String? = nil
    private(set) var isRepresentative:Bool? = nil
    private(set) var isNeutered:Bool? = nil
}

struct PlaceData : Decodable {
    private(set) var placeId: Int? = nil
    private(set) var placeCategory: Int? = nil
    private(set) var location: String? = nil
    private(set) var name: String? = nil
    private(set) var googlePlaceId: String? = nil
    private(set) var createdAt: String? = nil
    private(set) var visitorCnt:Int? = nil
    private(set) var isVisited:Bool? = nil
    private(set) var visitors: [UserAndPet]? = nil
    private(set) var place:MissionPlace? = nil
    private(set) var point:Int? = nil
    private(set) var exp:Double? = nil
}


struct ViewPortData : Decodable {
    private(set) var northeast: GeoData? = nil
    private(set) var southwest: GeoData? = nil
}

struct GeoData : Decodable {
    private(set) var lat: Double? = nil
    private(set) var lng: Double? = nil
}
