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
    case updatedPlayData, updatedLvData
}

class User:ObservableObject, PageProtocol, Identifiable{
    private(set) var id:String = UUID().uuidString
    @Published private(set) var event:UserEvent? = nil {didSet{ if event != nil { event = nil} }}
    
    private(set) var point:Int = 0
    private(set) var lv:Int = 1
    private(set) var exp:Double = 0
    private(set) var nextExp:Double = 0
    
    private(set) var exerciseDuration:Double = 0
    private(set) var totalWalkDistance:Double = 0
    private(set) var totalMissionDistance:Double = 0
    private(set) var totalMissionCount: Int = 0
    private(set) var totalWalkCount: Int = 0
    private(set) var currentProfile:UserProfile = UserProfile(isMine: true)
   
    private(set) var pets:[PetProfile] = []
    private(set) var snsUser:SnsUser? = nil
    private(set) var recentMission:History? = nil
    private(set) var finalGeo:GeoData? = nil
    private(set) var isMe:Bool = false
    private(set) var characterIdx:Int = 0
    var currentPet:PetProfile? = nil
    init(isMe:Bool = false) {
        self.isMe = isMe
    }
    
    func isSameUser(_ user:User?) -> Bool{
        guard let id = user?.currentProfile.userId else { return false }
        return self.snsUser?.snsID == id
    }
    func isSameUser(_ user:UserProfile?) -> Bool{
        guard let id = user?.userId else { return false }
        return self.snsUser?.snsID == id
    }
    
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
    
    @discardableResult
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
    
    @discardableResult
    func setData(data:UserData) -> User {
        if self.snsUser == nil,  let type = SnsType.getType(code: data.providerType), let id = data.userId {
            self.snsUser = SnsUser(
                snsType: type,
                snsID: id,
                snsToken: ""
            )
        }
        
        self.point = data.point ?? 0
        self.lv = data.level ?? 1
        self.exp = data.exp ?? (Double(self.lv-1) * Lv.expRange)
        self.totalWalkCount = data.walkCompleteCnt ?? 0
        self.totalMissionCount = data.missionCompleteCnt ?? 0
        self.totalWalkDistance = data.walkDistance ?? 0
        self.totalMissionDistance = data.missionDistance ?? 0
        self.exerciseDuration = data.exerciseDuration ?? 0
        self.currentProfile.setData(data: data)
        self.updateExp(0)
        self.characterIdx = Int.random(in: 0...(Asset.character.rand.count-1))
        self.event = .updatedProfile(self.currentProfile)
        return self
    }
    
    func setData(data:[PetData], isMyPet:Bool = false){
        self.pets = zip(0..<data.count, data).map{ idx, profile in PetProfile(data: profile, isMyPet: isMyPet, index: idx)}
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
        self.event = .addedDog(profile)
    }
    
    func getPet(_ id :String) -> PetProfile? {
        return self.pets.first(where: {$0.id == id})
    }
    
    func missionCompleted(_ mission:Mission) {
        if !mission.isCompleted {return}
        switch mission.type {
        case .walk :
            self.totalWalkCount += 1
            self.totalWalkDistance += mission.playDistence
    
        default :
            self.totalMissionCount += 1
            self.totalMissionDistance += mission.distance
        }
        self.pets.filter{$0.isWith}.forEach{
            //$0.update(exp: Double(point))
            $0.missionCompleted(mission)
        }
        self.event = .updatedPlayData
    }
    
    func updateExp(_ exp:Double) {
        self.exp += exp
        self.lv = floor(self.exp / Lv.expRange).toInt() + 1
        self.nextExp = Double(self.lv) * Lv.expRange
        self.currentProfile.setLv(self.lv)
        self.event = .updatedLvData
    }
    func updatePoint(_ point:Int) {
        self.point += point
        self.event = .updatedLvData
    }
    func updateReward(_ exp:Double, point:Int) {
        self.point += point
        self.updateExp(exp)
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

enum Lv {
    case purple, blue, lightBlue, sky, lightSky, green, lightGreen, yellow , orange, red
    
    static let expRange:Double = 100
    
    var icon : String {
        switch self {
        case .purple : return Asset.icon.favorite_on
        case .blue : return Asset.icon.favorite_on
        case .lightBlue : return Asset.icon.favorite_on
        case .sky : return Asset.icon.favorite_on
        case .lightSky : return Asset.icon.favorite_on
        case .green : return Asset.icon.favorite_on
        case .lightGreen : return Asset.icon.favorite_on
        case .yellow : return Asset.icon.favorite_on
        case .orange : return Asset.icon.favorite_on
        case .red : return Asset.icon.favorite_on
        }
    }
    var color : Color {
        switch self {
        case .purple : return Color.init(rgb:0x9A7DEB)
        case .blue : return Color.init(rgb:0x7D88EB)
        case .lightBlue : return Color.init(rgb:0x7DA9EB)
        case .sky : return Color.init(rgb:0x7DCAEB)
        case .lightSky : return Color.init(rgb:0x71E4D0)
        case .green : return Color.init(rgb:0x51DF8A)
        case .lightGreen : return Color.init(rgb:0x9CEF6A)
        case .yellow : return Color.init(rgb:0xF8D41C)
        case .orange : return Color.init(rgb:0xFFAD31)
        case .red : return Color.brand.primary
        }
    }
    
    var title : String {
        switch self {
        case .purple : return "Heart Lv.1"
        case .blue : return "Heart Lv.2"
        case .lightBlue : return "Heart Lv.3"
        case .sky : return "Heart Lv.4"
        case .lightSky : return "Heart Lv.5"
        case .green : return "Heart Lv.6"
        case .lightGreen : return "Heart Lv.7"
        case .yellow : return "Heart Lv.8"
        case .orange : return "Heart Lv.9"
        case .red : return "Heart Lv.10"
        }
    }
        
    static func getLv(_ value:Int) -> Lv{
        switch value{
        case 0...10 : return .purple
        case 10...20 : return .blue
        case 20...30 : return .lightBlue
        case 30...40 : return .sky
        case 40...50 : return .lightSky
        case 50...60 : return .green
        case 60...70 : return .lightGreen
        case 70...80 : return .yellow
        case 80...90 : return .orange
        case 90...100 : return .red
        default : return .red
        }
    }
}

enum FriendStatus{
    case norelation, requestFriend, friend, recieveFriend
    var icon:String{
        switch self {
        case .requestFriend : return Asset.icon.check
        case .friend : return Asset.icon.remove_friend
        case .recieveFriend : return Asset.icon.add_friend
        default : return Asset.icon.add_friend
        }
    }
    var text:String{
        switch self {
        case .requestFriend : return String.button.requestSent
        case .friend : return String.button.remopveFriend
        case .recieveFriend : return String.button.addFriend
        default : return String.button.addFriend
        }
    }
    var buttons:[FriendButton.ButtonType]{
        switch self {
        case .requestFriend : return [.requested]
        case .friend : return [.delete]
        case .recieveFriend : return [.reject, .accept]
        default : return [.request]
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
