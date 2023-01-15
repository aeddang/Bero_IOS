//
//  Map.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/19.
//

import Foundation
import GoogleMaps
import CoreLocation
import SwiftUI

struct MapMarker {
    var id:String = UUID.init().uuidString
    let marker:GMSMarker
    var rotation:CLLocationDegrees? = nil
    var isRotationMap = false
}

struct MapCircle {
    var id:String = UUID.init().uuidString
    let marker:GMSCircle
}

struct MapRoute {
    var id:String = UUID.init().uuidString
    let line:GMSPolyline
}

enum MapUiEvent {
    case me(MapMarker , follow:CLLocation? = nil),
         addMarker(MapMarker), addMarkers([MapMarker]),
         addCircle(MapCircle), addCircles([MapCircle]),
         addRoute(MapRoute), addRoutes([MapRoute]), clearAllRoute,
         clearAll([String]? = nil, exception:[String]? = nil), clear(String),
         move(CLLocation, rotate:Double? = nil, zoom:Float? = nil, angle:Double? = nil, duration:Double? = nil)

    case zip([MapUiEvent])
}

enum MapViewEvent {
    case tabMarker(GMSMarker), tabOffMarker(GMSMarker), move(isUser:Bool), tab(CLLocation)
}

protocol MapUserDataProtocal {
    var isSelected:Bool { get }
    var isGroup:Bool { get }
    var startPos:CGFloat { get }
    var midPos:CGFloat { get }
    var endPos:CGFloat { get }
    var title:String? { get }
    var location:CLLocation? { get }
    var locations:[CLLocation] { get }
    var count:Int { get }
    var color:Color { get }
}
open class MapUserData: InfinityData, MapUserDataProtocal, PageProtocol, Comparable{
    var isSelected:Bool = false
    private(set) var isGroup:Bool = false
    private(set) var startPos:CGFloat = 0
    private(set) var midPos:CGFloat = 0
    private(set) var endPos:CGFloat = 0
    open var title:String? = nil
    open var location:CLLocation? = nil
    open var locations:[CLLocation] = []
    open var count:Int = 0
    open var color:Color = .white
    
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
    
    func addCount(count:Int = 1, loc:CLLocation){
        self.count = self.count + count
        self.locations.append(loc)
    }
    func addCompleted(){
        var latSum: Double = 0
        var lngSum: Double = 0
        let count:Double = Double(self.locations.count)
        self.locations.forEach{ loc in
            latSum += loc.coordinate.latitude
            lngSum += loc.coordinate.longitude
        }
        self.isGroup = true
        self.location =  CLLocation(latitude: latSum/count, longitude: lngSum/count)
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
