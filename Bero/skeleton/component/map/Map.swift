//
//  Map.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/19.
//

import Foundation
import GoogleMaps
import CoreLocation

struct MapMarker {
    var id:String = UUID.init().uuidString
    let marker:GMSMarker
    var rotation:CLLocationDegrees? = nil
    var isRotationMap = false
}


enum MapUiEvent {
    case addMarker(MapMarker), addMarkers([MapMarker ]), me(MapMarker , follow:CLLocation? = nil) ,
         move(CLLocation, zoom:Float? = nil, angle:Double? = nil, duration:Double? = nil)
}

enum MapViewEvent {
    case selectedMarker(GMSMarker), tabMarker(GMSMarker)
}

open class MapModel: ComponentObservable {
    var startLocation:CLLocation = CLLocation()
    var zoom:Float = 6.0
    var angle:Double = 0.0
    @Published var uiEvent:MapUiEvent? = nil{
        willSet{
            self.status = .update
        }
        didSet{
            if uiEvent == nil {
                self.status = .ready
            }
        }
    }
    @Published var event:MapViewEvent? = nil{
        didSet{
            if event != nil { self.event = nil }
        }
    }
}
