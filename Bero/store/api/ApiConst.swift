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
    case search, summary, newMissions, directions, visit, monthlyList
    case isRequested, requesting, request, accept, reject
    case read, send
    case histories, list
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
    case registPet(SnsUser, ModifyPetProfileData), getPets(SnsUser, isCanelAble:Bool? = true), getPet(petId:Int),
         updatePet(petId:Int, ModifyPetProfileData), updatePetImage(petId:Int, UIImage?),
         deletePet(petId:Int)
    
    case getMission(userId:String? = nil,petId:Int? = nil, date:Date? = nil, MissionApi.Category , page:Int? = nil, size:Int? = nil),
         searchMission(MissionApi.Category, MissionApi.SearchType, searchValue:String? = nil,
                       location:CLLocation? = nil, distance:Double? = nil, page:Int? = nil, size:Int? = nil),
         requestNewMission(CLLocation? = nil, distance:Double? = nil), requestRoute(departure:CLLocation, destination:CLLocation, missionId:String? = nil),
         completeMission(Mission, [PetProfile], image:String? = nil),
         getMissionSummary(petId:Int), getMonthlyMission(userId:String, date:Date)
    
    case checkHumanWithDog(img:UIImage,thumbImg:UIImage)
    
    case getAlbumPictures(id:String?, AlbumApi.Category, searchType:AlbumApi.SearchType = .all , page:Int? = nil, size:Int? = nil),
         registAlbumPicture(img:UIImage, thumbImg:UIImage, id:String, AlbumApi.Category),
         deleteAlbumPictures(ids:String),
         updateAlbumPicture(pictureId:Int, isLike:Bool)
    
    case getWeather(CLLocation),
         getWeatherCity(id:String, type:ApiAction = .cities),
         getCode(category:MiscApi.Category, searchKeyword:String? = nil),
         sendReport(reportType:MiscApi.ReportType, postId:String? = nil, userId : String? = nil)
   
    case getPlace(CLLocation, distance:Double? = nil, searchType:String? = nil),
         registVisit(Place)
    
    case getFriend (page:Int? = nil, size:Int? = nil),
         getRequestFriend(page:Int? = nil, size:Int? = nil),
         getRequestedFriend(page:Int? = nil, size:Int? = nil),
         requestFriend(userId:String), deleteFriend(userId:String),
         rejectFriend(userId:String), acceptFriend(userId:String)
    
    case getRewardHistory(userId:String, page:Int? = nil, size:Int? = nil)
    
    case getChats (userId:String, page:Int? = nil, size:Int? = nil),
         deleteChat(chatId:Int),
         deleteAllChat(chatIds:String),
         sendChat(userId:String, contents:String),
         getChatRooms (page:Int? = nil, size:Int? = nil),
         readChatRoom(roomId:Int),
         deleteChatRoom(roomId:Int)
    
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
