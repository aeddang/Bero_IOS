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
    private(set) var prevExp:Double = 0
    private(set) var nextExp:Double = 0
    
    private(set) var exerciseDuration:Double = 0
    private(set) var exerciseDistance:Double = 0
    private(set) var totalWalkCount: Int = 0
    private(set) var currentProfile:UserProfile = UserProfile(isMine: true)
   
    private(set) var pets:[PetProfile] = []
    private(set) var snsUser:SnsUser? = nil
    private(set) var finalGeo:GeoData? = nil
    private(set) var isMe:Bool = false
    private(set) var characterIdx:Int = 0
    @Published private(set) var representativePet:PetProfile? = nil
    var currentPet:PetProfile? = nil
    
    init(isMe:Bool = false) {
        self.isMe = isMe
    }
    var userId:String? {
        return  self.snsUser?.snsID ?? (self.currentProfile.userId.isEmpty ?  nil : self.currentProfile.userId)
    }
    var representativeName:String {
        return  self.representativePet?.name ?? self.currentProfile.nickName ?? "bero user"
    }
    var representativeImage:String? {
        return  self.representativePet?.imagePath ?? self.currentProfile.imagePath
    }
    var isFriend:Bool {
        return self.currentProfile.status.isFriend
    }
    
    func isSameUser(_ user:User?) -> Bool{
        guard let id = user?.currentProfile.userId else { return false }
        return self.snsUser?.snsID == id
    }
    func isSameUser(_ user:UserProfile?) -> Bool{
        guard let id = user?.userId else { return false }
        return self.snsUser?.snsID == id
    }
    func isSameUser(userId:String?) -> Bool{
        guard let id = userId else { return false }
        return self.snsUser?.snsID == id
    }
    
    func registUser(user:SnsUser){
        self.snsUser = user
    }
    func clearUser(){
        self.snsUser = nil
        self.currentProfile = UserProfile(isMine: true)
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
    func setData(_ data:WalkData, isMe:Bool = false) -> User {
        if let user = data.user {
            self.setData(data:user)
        }
        if let pets = data.pets {
            self.setData(data:pets, isMyPet:isMe)
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
    func setData(_ data:MissionData) -> User {
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
        self.prevExp = data.prevLevelExp ?? (Double(self.lv-1) * Lv.expRange)
        self.nextExp = data.nextLevelExp ?? (Double(self.lv) * Lv.expRange)
        self.totalWalkCount = data.walkCompleteCnt ?? 0
        self.exerciseDistance = data.exerciseDistance ?? 0
        self.exerciseDuration = data.exerciseDuration ?? 0
        self.currentProfile.setData(data: data)
        self.currentProfile.setLv(self.lv)
        self.characterIdx = Int.random(in: 0...(Asset.character.rand.count-1))
        self.event = .updatedProfile(self.currentProfile)
        return self
    }
    
    func setData(data:[PetData], isMyPet:Bool = false){
        self.pets = zip(0..<data.count, data).map{ idx, profile in
            let pet = PetProfile(data: profile, isMyPet: isMyPet, index: idx)
            pet.level = self.lv
            return pet
        }
        self.findRepresentativePet()
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
        if profile.isRepresentative {
            self.representativePet = profile
        }
        self.event = .addedDog(profile)
    }
    
    func representativePetChanged(petId:Int){
        self.pets.forEach{
            $0.isRepresentative = $0.petId == petId
        }
        self.findRepresentativePet()
        self.event = .updatedDogs
    }
    private func findRepresentativePet(){
        self.pets.sort(by: {$0.sortIdx < $1.sortIdx})
        self.representativePet = self.pets.first(where: {$0.isRepresentative})
    }
    
    
    func getPet(_ id :String) -> PetProfile? {
        return self.pets.first(where: {$0.id == id})
    }
    
    func missionCompleted(_ mission:Mission) {
        if !mission.isCompleted {return}
        switch mission.type {
        case .walk :
            self.totalWalkCount += 1
            self.exerciseDistance += mission.distance
            self.exerciseDuration += mission.duration
        default :
            break
        }
        self.pets.filter{$0.isWith}.forEach{
            //$0.update(exp: Double(point))
            $0.missionCompleted(mission)
        }
        self.event = .updatedPlayData
    }
    func isLevelUp(lvData:MetaData?) -> Bool{
        guard let lv = lvData?.level else {return false }
        if let next = lvData?.nextLevelExp {
            self.nextExp = next
        }
        if let prev = lvData?.prevLevelExp {
            self.prevExp = prev
        }
        if self.lv < lv {
            self.lv = lv
            self.currentProfile.setLv(self.lv)
            return true
        }
        return false
    }
    
    func updateExp(_ exp:Double) {
        self.exp += exp
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
    case male, female, neutral
    var icon : String? {
        switch self {
        case .male : return Asset.icon.male
        case .female : return Asset.icon.female
        case .neutral : return Asset.icon.neutrality
        }
    }
    var color : Color {
        switch self {
        case .male : return Color.app.blue
        case .female : return  Color.app.orange
        case .neutral : return  Color.app.green
        }
    }
    
    var title : String {
        switch self {
        case .male : return String.app.male
        case .female : return String.app.female
        case .neutral : return String.app.neutral
        }
    }
    

    var coreDataKey:Int {
        switch self {
        case .male : return 1
        case .female : return 2
        case .neutral : return 3
        }
    }
    var apiDataKey:String {
        switch self {
        case .male : return "Male"
        case .female : return "Female"
        case .neutral : return "Neutral"
        }
    }
    
    static func getGender(_ value:Int) -> Gender?{
        switch value{
        case 1 : return .male
        case 2 : return .female
        case 3 : return .neutral
        default : return nil
        }
    }
    static func getGender(_ value:String?) -> Gender?{
        switch value{
        case "Male" : return .male
        case "Female" : return .female
        case "Neutral" : return .neutral
        default : return nil
        }
    }
}

enum Lv {
    case green, blue, yellow, pink, orange
    
    static let expRange:Double = 100
    static let prefix:String = "Lv."
    var icon : String {
        switch self {
        case .green : return "lv_green"
        case .blue : return "lv_blue"
        case .yellow : return "lv_yellow"
        case .pink : return "lv_pink"
        case .orange : return "lv_orange"
        }
    }
    var effect : String {
        switch self {
        case .green : return "lv_effect"
        case .blue : return "lv_effect"
        case .yellow : return "lv_effect"
        case .pink : return "lv_effect"
        case .orange : return "lv_effect"
        }
    }
    var color : Color {
        switch self {
        case .green : return Color.app.green
        case .blue : return Color.app.blue
        case .yellow : return Color.app.yellow
        case .pink : return Color.app.pink
        case .orange : return Color.app.orange
        }
    }
    var title : String {
        switch self {
        case .green : return "Avocado"
        case .blue : return "Blueberry"
        case .yellow : return "Banana"
        case .pink : return "Peach"
        case .orange : return "Carrot"
        }
    }
    static func getLv(_ value:Int) -> Lv{
        switch value{
        case 0...5 : return .green
        case 5...10 : return .blue
        case 10...15 : return .yellow
        case 15...20 : return .pink
        default : return .orange
        }
    }
}

enum FriendStatus{
    case norelation, requestFriend, friend, recieveFriend, chat, move(isFriend:Bool)
    var icon:String{
        switch self {
        case .chat : return Asset.icon.chat
        case .requestFriend : return Asset.icon.check
        case .friend : return Asset.icon.remove_friend
        case .recieveFriend : return Asset.icon.add_friend
        case .move( let isFriend) : return isFriend ? Asset.icon.chat : Asset.icon.add_friend
        default : return Asset.icon.add_friend
        }
    }
    var text:String{
        switch self {
        case .chat : return String.button.chat
        case .requestFriend : return String.button.requestSent
        case .friend : return String.button.removeFriend
        case .recieveFriend : return String.button.addFriend
        case .move( let isFriend) : return isFriend ? String.button.chat : String.button.addFriend
        default : return String.button.addFriend
        }
    }
    var buttons:[FriendButton.FuncType]{
        switch self {
        case .chat : return [.chat]
        case .requestFriend : return []
        case .friend : return [.delete]
        case .recieveFriend : return [.reject, .accept]
        case .move( let isFriend) : return isFriend ? [.move, .chat] : [.move, .request]
        default : return [.request]
        }
    }
    var isFriend:Bool {
        switch self {
        case .friend, .chat : return true
        case .move(let isFriend) : return isFriend
        default : return false
        }
    }
    var useMore:Bool {
        switch self {
        case .chat : return false
        default : return true
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
    private(set) var missionCategory:MissionApi.Category? = nil
    init(data:MissionData, idx:Int = 0){
        super.init()
        self.missionCategory = MissionApi.Category.getCategory(data.missionCategory)
        self.missionId = data.missionId
        self.title = data.title
        self.imagePath = data.pictureUrl
        self.description = data.description
        self.duration = data.duration
        self.distance = data.distance
        self.point = data.point ?? 0
        self.date = data.createdAt?.toDate()?.toDateFormatter(dateFormat: "yy-MM-dd HH:mm")
        self.index = idx
    }
}
