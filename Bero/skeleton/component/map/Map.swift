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
    case tabMarker(GMSMarker), tabOffMarker(GMSMarker), move(isUser:Bool)
}

protocol MapUserDataProtocal {
    var isSelected:Bool { get }
    var startPos:CGFloat { get }
    var midPos:CGFloat { get }
    var endPos:CGFloat { get }
}
open class MapUserData: InfinityData, MapUserDataProtocal, PageProtocol, Comparable{
    var isSelected:Bool = false
    private(set) var startPos:CGFloat = 0
    private(set) var midPos:CGFloat = 0
    private(set) var endPos:CGFloat = 0
    func setPosition(pos:CGFloat)->MapUserData{
        self.midPos = pos 
        return self
    }
    
    @discardableResult
    func setRange(idx:Int, width:CGFloat)->MapUserData{
        self.index = idx
        let sPos = CGFloat(idx) * width
        let range = (width / 2)
        self.startPos = sPos
        self.endPos = sPos + width
        self.midPos = sPos + range
        return self
    }
    func isBelong(pos:CGFloat)->Bool{
        if self.startPos <= pos && self.endPos > pos {
            return true
        }
        return false
    }
    public static func == (lhs: MapUserData, rhs: MapUserData) -> Bool {
        return rhs.isBelong(pos: lhs.midPos) || lhs.isBelong(pos: rhs.midPos)
    }
    
    public static func < (lhs: MapUserData, rhs: MapUserData) -> Bool {
        if lhs == rhs {return false}
        return lhs.midPos < rhs.midPos
    }
    public static func > (lhs: MapUserData, rhs: MapUserData) -> Bool {
        if lhs == rhs {return false}
        return lhs.midPos > rhs.midPos
    }
}


open class MapModel: ComponentObservable {
    var startLocation:CLLocation = CLLocation()
    var zoom:Float = 6.0
    var angle:Double = 0.0
    
    @Published var position: GMSCameraPosition? = nil
    
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
