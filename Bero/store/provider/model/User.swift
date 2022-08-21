//
//  Profile.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/19.
//

import Foundation
import SwiftUI
import UIKit


enum UserEvent{
    case updatedProfile(UserProfile)
    case addedDog(PetProfile), deletedDog(PetProfile), updatedDog(PetProfile) , updatedDogs
    case updatedPlayData
}

class User:ObservableObject, PageProtocol, Identifiable{
    private(set) var id:String = UUID().uuidString
    @Published private(set) var event:UserEvent? = nil {didSet{ if event != nil { event = nil} }}
    
    private(set) var point:Int = 0
    private(set) var lv:Int = 1
    private(set) var exp:Double = 70
    private(set) var nextExp:Double = 100
    private(set) var mission:Double = 0
    
    private(set) var currentProfile:UserProfile = UserProfile()
    private(set) var currentPet:PetProfile? = nil
    private(set) var pets:[PetProfile] = []
    private(set) var snsUser:SnsUser? = nil
    private(set) var recentMission:History? = nil
    private(set) var finalGeo:GeoData? = nil
    
    
    func registUser(user:SnsUser){
        self.snsUser = user
    }
    func clearUser(){
        self.snsUser = nil
    }
    func registUser(id:String?, token:String?, code:String?){
        DataLog.d("id " + (id ?? ""), tag: self.tag)
        DataLog.d("token " + (token ?? ""), tag: self.tag)
        DataLog.d("code " + (code ?? ""), tag: self.tag)
        guard let id = id, let token = token , let type = SnsType.getType(code: code) else {return}
        DataLog.d("user init " + (code ?? ""), tag: self.tag)
        self.snsUser = SnsUser(snsType: type, snsID: id, snsToken: token)
    }
    
    func setData(_ data:MissionData) -> User {
        self.recentMission = History(data: data)
        if let user = data.user {
            self.setData(data:user)
        }
        if let pets = data.pets {
            self.setData(data:pets, isMyPet:false)
        }
        if let type = SnsType.getType(code: data.user?.providerType), let id = data.user?.userId {
            self.snsUser = SnsUser(
                snsType: type,
                snsID: id,
                snsToken: ""
            )
        }
        self.finalGeo = data.geos?.first
        return self
    }
    
    func setData(data:UserData){
        self.point = data.point ?? 0
        self.currentProfile.setData(data: data)
        self.event = .updatedProfile(self.currentProfile)
    }
    
    func setData(data:[PetData], isMyPet:Bool = true){
        self.pets = data.map{ PetProfile(data: $0, isMyPet: isMyPet)}
        self.event = .updatedDogs
    }
    
    func deletePet(petId:Int) {
        guard let find = self.pets.firstIndex(where: {$0.petId == petId}) else {
            return
        }
        let pet = self.pets.remove(at: find)
        self.event = .deletedDog(pet)
    }
    
    func registPetComplete(profile:PetProfile)  {
        self.pets.append(profile)
        if self.currentPet == nil {
            self.currentPet = profile
        }
        self.event = .addedDog(profile)
    }
    
    func getPet(_ id :String) -> PetProfile? {
        return self.pets.first(where: {$0.id == id})
    }
    
    func missionCompleted(_ mission:Mission) {
        if !mission.isCompleted {return}
        let point =  mission.point
        self.point += point
        self.mission += 1
        self.pets.filter{$0.isWith}.forEach{
            $0.update(exp: Double(point))
        }
        self.event = .updatedPlayData
    }
    
}


enum Gender:String {
    case male, female
    var icon : String {
        switch self {
        case .male : return Asset.icon.male
        case .female : return Asset.icon.female
        }
    }
    var color : Color {
        switch self {
        case .male : return Color.app.blue
        case .female : return  Color.app.orange
        }
    }
    
    var title : String {
        switch self {
        case .male : return String.app.male
        case .female : return String.app.female
        }
    }
    

    var coreDataKey:Int {
        switch self {
        case .male : return 1
        case .female : return 2
        }
    }
    var apiDataKey:String {
        switch self {
        case .male : return "Male"
        case .female : return "Female"
        }
    }
    
    static func getGender(_ value:Int) -> Gender?{
        switch value{
        case 1 : return .male
        case 2 : return .female
        default : return nil
        }
    }
    static func getGender(_ value:String?) -> Gender?{
        switch value{
        case "Male" : return .male
        case "Female" : return .female
        default : return nil
        }
    }
}

struct ModifyUserData {
    var point:Double?
    var mission:Double?
    var coin:Double?
}

class History:InfinityData {
   
    private(set) var missionId: Int? = nil
    private(set) var category: String? = nil
    private(set) var title: String? = nil
    private(set) var imagePath: String? = nil
    private(set) var description: String? = nil
    private(set) var date: String? = nil
    private(set) var duration: Double? = nil
    private(set) var distance: Double? = nil
    private(set) var point: Int? = nil
    private(set) var lv:MissionLv? = nil
    private(set) var missionCategory:MissionApi.Category? = nil
    init(data:MissionData, idx:Int = 0){
        super.init()
        self.missionCategory = MissionApi.Category.getCategory(data.missionCategory)
        self.missionId = data.missionId
        self.title = data.title
        self.imagePath = data.pictureUrl
        self.description = data.description
        self.lv = MissionLv.getMissionLv(data.difficulty)
        self.duration = data.duration
        self.distance = data.distance
        self.point = data.point ?? 0
        self.date = data.createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")?.toDateFormatter(dateFormat: "yy-MM-dd HH:mm")
        self.index = idx
    }
}
