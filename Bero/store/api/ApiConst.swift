//
//  ApiConst.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import AVFAudio

struct ApiPath {
    static func getRestApiPath() -> String {
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            let dictRoot = NSDictionary(contentsOfFile: path)
            if let dict = dictRoot {
                return dict["RestApiPath"] as? String ?? ""
            }
        }
        return ""
    }
}

struct ApiConst {
    static let pageSize = 24
}

struct ApiCode {
    static let error = "E001"
    static let unknownError = "E999"
}

enum ApiAction:String{
    case login, pushToken
    case detecthumanwithdog, thumbsup, cities
    case search, summary, newMissions, directions, visit, visitors, monthlyList
    case isRequested, requesting, request, accept, reject
    case read, send
    case histories, list
    case friends, explorer
}

enum ApiValue:String{
    case video
}
      
enum ApiType{
    case registPush(token:String), getUser(SnsUser, isCanelAble:Bool? = true), getUserDetail(userId:String),
         updateUser(SnsUser, ModifyUserProfileData), updateUserImage(SnsUser, UIImage?),
         getBlockedUser(page:Int? = nil, size:Int? = nil), blockUser(userId:String, isBlock:Bool),
         deleteUser
    
    case joinAuth(SnsUser, SnsUserInfo?), reflashAuth
    case registPet(SnsUser, ModifyPetProfileData, isRepresentative:Bool), getPets(userId:String, isCanelAble:Bool? = true), getPet(petId:Int),
         updatePet(petId:Int, ModifyPetProfileData), updatePetImage(petId:Int, UIImage?),
         deletePet(petId:Int), changeRepresentativePet(petId:Int)
    
    case getMission(userId:String? = nil,petId:Int? = nil, date:Date? = nil, MissionApi.Category , page:Int? = nil, size:Int? = nil),
         searchMission(MissionApi.Category, MissionApi.SearchType, searchValue:String? = nil,
                       location:CLLocation? = nil, distance:Double? = nil, page:Int? = nil, size:Int? = nil),
         requestNewMission(CLLocation? = nil, distance:Double? = nil), requestRoute(departure:CLLocation, destination:CLLocation, missionId:String? = nil),
         completeMission(Mission, [PetProfile], image:String? = nil)
         
    case getWalk(walkId:Int), getWalks(date:Date?), getUserWalks(userId:String? = nil, page:Int? = nil, size:Int? = nil),
         searchLatestWalk(loc:CLLocation, radius:Int, min:Int),
         searchWalk(loc:CLLocation, radius:Int, min:Int, page:Int? = nil, size:Int? = nil),
         searchWalkFriends(page:Int? = nil, size:Int? = nil),
         registWalk(loc:CLLocation, [PetProfile]),
         updateWalk(walkId:Int, loc:CLLocation, additionalData:WalkadditionalData? = nil),
         completeWalk(walkId:Int, loc:CLLocation, additionalData:WalkadditionalData? = nil),
         getWalkSummary(petId:Int), getMonthlyWalk(userId:String, date:Date)
    
    case checkHumanWithDog(img:UIImage,thumbImg:UIImage)
    
    case getAlbumPictures(userId:String?, referenceId:String? = nil, AlbumApi.Category, searchType:AlbumApi.SearchType = .all , isExpose:Bool? = nil, page:Int? = nil, size:Int? = nil),
         getAlbumExplorer(randId:String, searchType:AlbumApi.SearchType = .all, page:Int? = nil, size:Int? = nil),
         registAlbumPicture(img:UIImage, thumbImg:UIImage, userId:String, AlbumApi.Category, isExpose:Bool = false, referenceId:String? = nil),
         deleteAlbumPictures(ids:String),
         updateAlbumPicture(pictureId:Int, isLike:Bool? = nil, isExpose:Bool? = nil)
    
    case getWeather(CLLocation),
         getWeatherCity(id:String, type:ApiAction = .cities),
         getCode(category:MiscApi.Category, searchKeyword:String? = nil),
         sendReport(reportType:MiscApi.ReportType, postId:String? = nil, userId : String? = nil),
         getBanner(id:String, dateValue:String?),
         getAlarm(page:Int? = nil, size:Int? = nil)
   
    case getPlace(CLLocation, distance:Double? = nil, searchType:String? = nil, zip:String? = nil),
         getPlaceVisitors(placeId:Int, page:Int? = nil, size:Int? = nil),
         registVisit(Place)
    
    case getFriend (userId:String? = nil, page:Int? = nil, size:Int? = nil),
         getRequestFriend(page:Int? = nil, size:Int? = nil),
         getRequestedFriend(page:Int? = nil, size:Int? = nil),
         requestFriend(userId:String), deleteFriend(userId:String),
         rejectFriend(userId:String), acceptFriend(userId:String)
    
    case getRewardHistory(userId:String, type:RewardApi.ValueType, page:Int? = nil, size:Int? = nil)
    
    case getChats (userId:String, page:Int? = nil, size:Int? = nil),
         getRoomChats (roomId:Int, page:Int? = nil, size:Int? = nil),
         deleteChat(chatId:Int),
         deleteAllChat(chatIds:String),
         sendChat(userId:String, contents:String),
         getChatRooms (page:Int? = nil, size:Int? = nil),
         readChatRoom(roomId:Int),
         deleteChatRoom(roomId:Int)
    case getRecommandationFriends
    
    func coreDataKey() -> String? {
        switch self {
        case .getCode(let category, let searchKeyword) :
            if searchKeyword?.isEmpty == false {return nil}
            else { return category.apiCoreKey }
        default : return nil
        }
    }
    func transitionKey() -> String {
        switch self {
        default : return ""
        }
    }
}
