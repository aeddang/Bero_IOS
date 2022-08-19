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
    case login, detecthumanwithdog, thumbsup, cities
    case search, summary, newMissions, directions, visit
}

enum ApiValue:String{
    case video
}
      
enum ApiType{
    case getUser(SnsUser, isCanelAble:Bool? = true), updateUser(SnsUser, ModifyUserProfileData)
    case joinAuth(SnsUser, SnsUserInfo?), reflashAuth
    case registPet(SnsUser, ModifyPetProfileData), getPets(SnsUser, isCanelAble:Bool? = true), getPet(petId:Int),
         updatePet(petId:Int, ModifyPetProfileData), updatePetImage(petId:Int, UIImage),
         deletePet(petId:Int)
    
    case getMission(userId:String? = nil,petId:Int? = nil, MissionApi.Category , page:Int? = nil, size:Int? = nil),
         searchMission(MissionApi.Category, MissionApi.SearchType, location:CLLocation? = nil, distance:Double? = nil, page:Int? = nil, size:Int? = nil),
         requestNewMission(CLLocation? = nil, distance:Double? = nil), requestRoute(departure:CLLocation, destination:CLLocation),
         completeMission(Mission, [PetProfile]),completeWalk(Walk, [PetProfile]),
         getMissionSummary(petId:Int)
    
    case checkHumanWithDog(UIImage)
    
    case getAlbumPictures(id:String, AlbumApi.Category, page:Int? = nil, size:Int? = nil),
         registAlbumPicture(img:UIImage, thumbImg:UIImage, id:String, AlbumApi.Category),
         deleteAlbumPictures(ids:String),
         updateAlbumPictures(pictureId:Int, isLike:Bool)
    
    case getWeather(CLLocation),
         getWeatherCity(id:String, type:ApiAction = .cities),
         getCode(category:MiscApi.Category, searchKeyword:String? = nil)
   
    case getPlace(CLLocation),
         registVisit(Place)
    
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
