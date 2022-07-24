//
//  PetApiData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/12/24.
//

import Foundation


struct PetData : Decodable {
    private(set) var petId: Int? = nil
    
    private(set) var name: String? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var breed: String? = nil
    private(set) var birthdate: String? = nil
    private(set) var sex: String? = nil
    private(set) var regNumber: String? = nil
    private(set) var level: String? = nil
    private(set) var status: String? = nil
    private(set) var exerciseDistance: Double? = nil
    private(set) var exerciseDuration: Double? = nil
    private(set) var experience: Double? = nil
    private(set) var weight: Double? = nil
    private(set) var size: Double? = nil
    private(set) var walkCompleteCnt: Int? = nil
    private(set) var missionCompleteCnt: Int? = nil
}
