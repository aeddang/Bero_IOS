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
    var nickName:String? = nil
    var species:String? = nil
    var gender:Gender? = nil
    var birth:Date? = nil
    var microfin:String? = nil
    var neutralization:Bool? = nil
    var distemper:Bool? = nil
    var hepatitis:Bool? = nil
    var parovirus:Bool? = nil
    var rabies:Bool? = nil
    var weight:Double? = nil
    var size:Double? = nil
}

struct ModifyPlayData {
    let lv:Int
    let exp:Double
}
extension PetProfile {
    static let expRange:Double = 100
    
    static func getStatusValue(_ profile:PetProfile)->[String]{
        var status:[String] = []
        if profile.neutralization == true {status.append("neutralization")}
        if profile.distemper == true {status.append("distemper")}
        if profile.hepatitis == true {status.append("hepatitis")}
        if profile.parovirus == true {status.append("parovirus")}
        if profile.rabies == true {status.append("rabies")}
        return status
    }
    static func getStatusValue(_ profile:ModifyPetProfileData)->[String]{
        var status:[String] = []
        if profile.neutralization == true {status.append("neutralization")}
        if profile.distemper == true {status.append("distemper")}
        if profile.hepatitis == true {status.append("hepatitis")}
        if profile.parovirus == true {status.append("parovirus")}
        if profile.rabies == true {status.append("rabies")}
        return status
    }
}


class PetProfile:ObservableObject, PageProtocol, Identifiable, Equatable {
    private(set) var id:String = UUID().uuidString
    private(set) var petId:Int = 0
    private(set) var imagePath:String? = nil
    @Published private(set) var image:UIImage? = nil
    @Published private(set) var nickName:String? = nil
    @Published private(set) var species:String? = nil
    @Published private(set) var gender:Gender? = nil
    @Published private(set) var birth:Date? = nil
    @Published private(set) var exp:Double = 0
    @Published private(set) var lv:Int = 0
    @Published private(set) var prevExp:Double = 0
    @Published private(set) var nextExp:Double = 0
    @Published private(set) var neutralization:Bool? = nil
    @Published private(set) var distemper:Bool? = nil
    @Published private(set) var hepatitis:Bool? = nil
    @Published private(set) var parovirus:Bool? = nil
    @Published private(set) var rabies:Bool? = nil
    
    @Published private(set) var microfin:String? = nil
    
    @Published private(set) var weight:Double? = nil
    @Published private(set) var size:Double? = nil
    private(set) var isEmpty:Bool = false
    private(set) var isMypet:Bool = false
    
    private(set) var totalExerciseDistance: Double? = nil
    private(set) var totalExerciseDuration: Double? = nil
    private(set) var totalMissionCount: Int? = nil
    private(set) var totalWalkCount: Int? = nil
    var isWith:Bool = true
    
    public static func == (l:PetProfile, r:PetProfile)-> Bool {
        return l.id == r.id
    }
    
    init(){}
    init(nickName:String?,species:String?, gender:Gender?, birth:Date?){
        self.nickName = nickName
        self.species = species
        self.gender = gender
        self.birth = birth
        self.isMypet = true
    }
    
    
    init(isMyPet:Bool){
        self.isMypet = isMyPet
    }
    init(data:PetData, isMyPet:Bool){
        self.isMypet = isMyPet
        self.petId = data.petId ?? 0
        self.imagePath = data.pictureUrl
        self.nickName = data.name
        self.species = data.breed
        self.gender = Gender.getGender(data.sex) 
        self.birth = data.birthdate?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
        self.exp = Double(data.experience ?? 0)
        self.microfin = data.regNumber
        self.weight = data.weight
        self.size = data.size
        self.neutralization = data.status?.contains("neutralization")
        self.distemper = data.status?.contains("distemper")
        self.hepatitis = data.status?.contains("hepatitis")
        self.parovirus = data.status?.contains("parovirus")
        self.rabies = data.status?.contains("rabies")
        self.totalExerciseDistance = data.exerciseDistance
        self.totalExerciseDuration = data.exerciseDuration
        self.totalMissionCount = data.missionCompleteCnt
        self.totalWalkCount = data.walkCompleteCnt
        self.updatedExp()
    }
    
    @discardableResult
    func empty() -> PetProfile{
        self.isEmpty = true
        self.nickName = ""
        self.isMypet = true
        return self
    }
    
    @discardableResult
    func setDummy() -> PetProfile{
        self.isMypet = false
        self.id = UUID().uuidString
        self.nickName = "bero"
        self.species = "bero species"
        self.gender = .female
        self.birth = Date()
        
        self.microfin = "19290192819281928"
        self.image =  UIImage(named: Asset.brand.logoLauncher)
        self.neutralization = true
        self.distemper = true
        self.hepatitis = true
        self.parovirus = true
        self.rabies = true
        self.totalExerciseDistance = 1
        self.totalExerciseDuration = 10
    
        return self.update(exp: 999)
    }
    
    @discardableResult
    func update(data:ModifyPetProfileData) -> PetProfile{
        if let value = data.image { self.image = value }
        if let value = data.nickName { self.nickName = value }
        if let value = data.species { self.species = value }
        if let value = data.gender { self.gender = value }
        if let value = data.microfin { self.microfin = value }
        if let value = data.birth { self.birth = value }
        if let value = data.neutralization { self.neutralization = value }
        if let value = data.distemper { self.distemper = value }
        if let value = data.hepatitis { self.hepatitis = value }
        if let value = data.parovirus { self.parovirus = value }
        if let value = data.rabies { self.rabies = value }
        
        if let value = data.weight { self.weight = value }
        if let value = data.size { self.size = value }
        //ProfileCoreData().update(id: self.id, data: data)
        return self
    }
    
    func recordSummry() -> String? {
        var summry = ""
        if let distance = self.totalExerciseDistance {
            summry += Mission.viewDistance(distance)
        }
        if let duration = self.totalExerciseDuration {
            if !summry.isEmpty {summry += " / "}
            summry += Mission.viewDuration(duration)
        }
        if summry.isEmpty {return nil}
        return summry
    }
    
    
    
    @discardableResult
    func update(image:UIImage?) -> PetProfile{
        self.image = image
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
        DataLog.d("prevExp " + self.prevExp.description, tag: self.tag)
        DataLog.d("nextExp " + self.nextExp.description, tag: self.tag)
        DataLog.d("lv " + self.lv.description, tag: self.tag)
    }
}
