//
//  Profile.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/06/06.
//

import Foundation
import SwiftUI
import UIKit

struct ModifyPetProfileData {
    var image:UIImage? = nil
    var name:String? = nil
    var breed:String? = nil
    var gender:Gender? = nil
    var birth:Date? = nil
    var microchip:String? = nil
    var animalId:String? = nil
    var immunStatus:String? = nil
    var hashStatus:String? = nil
    var introduction:String? = nil
    var weight:Double? = nil
    var size:Double? = nil
    
    func updata(_ data:ModifyPetProfileData) -> ModifyPetProfileData {
        return ModifyPetProfileData(
            image: data.image ?? self.image,
            name: data.name ?? self.name,
            breed: data.breed ?? self.breed,
            gender: data.gender ?? self.gender,
            birth: data.birth ?? self.birth,
            microchip: data.microchip ?? self.microchip,
            animalId: data.animalId ?? self.animalId,
            immunStatus: data.immunStatus ?? self.immunStatus,
            hashStatus: data.hashStatus ?? self.hashStatus,
            introduction: data.introduction ?? self.introduction,
            weight: data.weight ?? self.weight,
            size: data.size ?? self.size)
    }
}

struct ModifyPlayData {
    let lv:Int
    let exp:Double
}
extension PetProfile {
    static let expRange:Double = 100
    static func exchangeListToString(_ list:[String]?)->String{
        if list?.isEmpty == false, let list = list {
            return list.reduce("", {$0 + "," + $1}).subString(1)
        } else {
            return ""
        }
    }
    static func exchangeStringToList(_ str:String?)->[String]{
        if str?.isEmpty == false, let str = str {
            return str.components(separatedBy:",")
        } else {
            return []
        }
    }
}


class PetProfile:ObservableObject, PageProtocol, Identifiable, Equatable {
    private(set) var id:String = UUID().uuidString
    private(set) var petId:Int = -1
    private(set) var userId:String = ""
    private(set) var index:Int = -1
    @Published private(set) var imagePath:String? = nil
    @Published private(set) var image:UIImage? = nil
    @Published private(set) var name:String? = nil
    @Published private(set) var breed:String? = nil
    @Published private(set) var gender:Gender? = nil
    @Published private(set) var birth:Date? = nil
    @Published private(set) var introduction:String? = nil
    @Published private(set) var exp:Double = 0
    @Published private(set) var lv:Int = 0
    @Published private(set) var prevExp:Double = 0
    @Published private(set) var nextExp:Double = 0
    @Published private(set) var immunStatus:String? = nil
    @Published private(set) var hashStatus:String? = nil
    @Published private(set) var microchip:String? = nil
    @Published private(set) var animalId:String? = nil
    @Published private(set) var weight:Double? = nil
    @Published private(set) var size:Double? = nil
    private(set) var isEmpty:Bool = false
    private(set) var isMypet:Bool = false
    private(set) var totalExerciseDistance: Double? = nil
    private(set) var totalExerciseDuration: Double? = nil
    @Published private(set) var totalMissionCount: Int = 0
    @Published private(set) var totalWalkCount: Int = 0
    private(set) var originData:PetData? = nil
    var isWith:Bool = true
    var isRepresentative:Bool = false
    var isFriend:Bool = false
    var sortIdx:Int {
        self.isRepresentative ? 0 : 1
    }
    public static func == (l:PetProfile, r:PetProfile)-> Bool {
        return l.id == r.id
    }
    
    init(){}
    init(name:String?,breed:String?, gender:Gender?, birth:Date?){
        self.name = name
        self.breed = breed
        self.gender = gender
        self.birth = birth
        self.isMypet = true
    }
    
    
    init(isMyPet:Bool){
        self.isMypet = isMyPet
    }
    init(data:PetData, isMyPet:Bool = false, index:Int = -1){
        self.isMypet = isMyPet
        if isMyPet {
            self.originData = data
        }
        self.index = index
        self.petId = data.petId ?? 0
        if data.pictureUrl?.isEmpty == false {
            self.imagePath = data.pictureUrl
        }
        self.isRepresentative = data.isRepresentative ?? false
        self.userId = data.userId ?? ""
        self.name = data.name
        self.breed = data.tagBreed
        self.gender = Gender.getGender(data.sex) 
        self.birth = data.birthdate?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
        self.exp = Double(data.experience ?? 0)
        self.microchip = data.regNumber
        self.animalId = data.animalId
        self.weight = data.weight
        self.size = data.size
        self.immunStatus = data.tagStatus
        self.hashStatus = data.tagPersonality
        self.totalExerciseDistance = data.exerciseDistance
        self.totalExerciseDuration = data.exerciseDuration
        self.totalMissionCount = data.missionCompleteCnt ?? 0
        self.totalWalkCount = data.walkCompleteCnt ?? 0
        self.updatedExp()
        self.introduction = data.introduce
        if !(self.introduction?.isEmpty == false) , let name = data.name {
            self.introduction = String.pageText.introductionDefault.replace(name)
        }
    }
    

    @discardableResult
    func empty() -> PetProfile{
        self.isEmpty = true
        self.name = ""
        self.isMypet = true
        return self
    }
    
    @discardableResult
    func setDummy() -> PetProfile{
        self.isMypet = false
        self.id = UUID().uuidString
        self.name = "bero"
        self.breed = "1"
        self.gender = .female
        self.birth = Date()
        
        self.microchip = "19290192819281928"
        self.image =  UIImage(named: Asset.brand.logoLauncher)
        
        self.totalExerciseDistance = 1
        self.totalExerciseDuration = 10
    
        return self.update(exp: 999)
    }
    
    @discardableResult
    func update(data:ModifyPetProfileData) -> PetProfile{
        if let value = data.image { self.image = value }
        if let value = data.name { self.name = value }
        if let value = data.breed { self.breed = value }
        if let value = data.gender { self.gender = value }
        if let value = data.microchip { self.microchip = value }
        if let value = data.animalId { self.animalId = value }
        if let value = data.birth { self.birth = value }
        if let value = data.hashStatus { self.hashStatus  = value }
        if let value = data.immunStatus { self.immunStatus  = value }
        if let value = data.introduction { self.introduction  = value }
        if let value = data.weight { self.weight = value }
        if let value = data.size { self.size = value }
        
        //ProfileCoreData().update(id: self.id, data: data)
        return self
    }
    
    func recordSummry() -> String? {
        var summry = ""
        if let distance = self.totalExerciseDistance {
            summry += WalkManager.viewDistance(distance)
        }
        if let duration = self.totalExerciseDuration {
            if !summry.isEmpty {summry += " / "}
            summry += WalkManager.viewDuration(duration)
        }
        if summry.isEmpty {return nil}
        return summry
    }
    
    func missionCompleted(_ mission:Mission) {
        if !mission.isCompleted {return}
        switch mission.type {
        case .walk :
            self.totalWalkCount += 1
           
        default :
            self.totalMissionCount += 1
        }
        
    }
    
    @discardableResult
    func update(image:UIImage?) -> PetProfile{
        self.image = image
        if image == nil {
            self.imagePath = nil
        }
        return self
    }
    
    @discardableResult
    func update(exp:Double) -> PetProfile{
        self.exp += exp
        self.updatedExp()
        return self
    }
    
    private func updatedExp(){
        let willLv = Int(floor(self.exp / Self.expRange) + 1)
        if willLv != self.lv {
            self.lv = willLv
            self.updatedLv()
        }
        
    }
    private func updatedLv(){
        self.prevExp = Double(self.lv - 1) * Self.expRange
        self.nextExp = Double(self.lv) * Self.expRange
        //DataLog.d("prevExp " + self.prevExp.description, tag: self.tag)
        //DataLog.d("nextExp " + self.nextExp.description, tag: self.tag)
        //DataLog.d("lv " + self.lv.description, tag: self.tag)
    }
}
