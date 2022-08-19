//
//  Route.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/15.
//

import Foundation
import GooglePlaces

class Place:PageProtocol, Identifiable{
    let id:String = UUID().uuidString
    private(set) var placeId: Int? = nil
    private(set) var location:CLLocation? = nil
    private(set) var name: String? = nil
    private(set) var googlePlaceId: String? = nil
    private(set) var visitors: [PlaceVisitor] = []
    
    @discardableResult
    func setData(_ data:PlaceData)->Place{
        self.name = data.name
        self.googlePlaceId = data.googlePlaceId
        self.placeId = data.placeId
        if let locs = data.location?.components(separatedBy: " ") {
            if locs.count == 2 {
                let lat = locs[0].onlyNumric().toDouble()
                let long = locs[1].onlyNumric().toDouble()
                self.location = CLLocation(latitude: lat, longitude: long)
            }
        }
        self.visitors = data.visitors ?? []
        return self
    }
    
    
}



