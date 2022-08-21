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
    @discardableResult
    func setData(_ data:PlaceData)->Place{
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
        return self
    }
    
    
}



