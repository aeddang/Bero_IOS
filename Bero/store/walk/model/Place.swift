//
//  Route.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/15.
//

import Foundation
import GooglePlaces

class Place:MapUserData{
    private(set) var placeId: Int = 0
    private(set) var location:CLLocation? = nil
    private(set) var name: String? = nil
    private(set) var googlePlaceId: String? = nil
    private(set) var visitors: [PlaceVisitor] = []
    private(set) var playExp:Double = 0
    private(set) var playPoint:Int = 0
    private(set) var place:MissionPlace? = nil
    private(set) var isMark:Bool = false
    @discardableResult
    func setData(_ data:PlaceData, me:String)->Place{
        self.name = data.name
        self.googlePlaceId = data.googlePlaceId
        self.placeId = data.placeId ?? 0
        if let locs = data.location?.components(separatedBy: " ") {
            let latitude = locs[0].onlyNumric().toDouble()
            let longitude = locs[1].onlyNumric().toDouble()
            if locs.count == 2 {
                let lat = latitude
                let long = longitude
                self.location = CLLocation(latitude: lat, longitude: long)
            }
        }
        self.visitors = data.visitors ?? []
        self.place = data.place ?? MissionPlace()
        self.isMark = self.visitors.first(where: {$0.userId == me}) != nil
        return self
    }
     
    func addMark(user:User){
        self.isMark = true
        self.visitors.append(.init(userId: user.snsUser?.snsID, userName: user.currentProfile.nickName))
    }
    
}



