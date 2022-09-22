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

struct MapRoute {
    var id:String = UUID.init().uuidString
    let line:GMSPolyline
    var rotation:CLLocationDegrees? = nil
    var isRotationMap = false
}

enum MapUiEvent {
    case me(MapMarker , follow:CLLocation? = nil),
         addMarker(MapMarker), addMarkers([MapMarker ]),
         addRoute(MapRoute), addRoutes([MapRoute]), clearAllRoute,
         clearAll([String]? = nil), clear(String),
         move(CLLocation, rotate:Double? = nil, zoom:Float? = nil, angle:Double? = nil, duration:Double? = nil)
    case zip([MapUiEvent])
}

enum MapViewEvent {
    case tabMarker(GMSMarker), move(isUser:Bool)
}

protocol MapUserDataProtocal: Identifiable, Equatable{
    var isSelected:Bool { get }
}
open class MapUserData: MapUserDataProtocal, PageProtocol{
    public let id:String = UUID().uuidString
    var isSelected:Bool = false
    public static func == (l:MapUserData, r:MapUserData)-> Bool {
        return l.id == r.id
    }
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
