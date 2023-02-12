//
//  Route.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/15.
//

import Foundation
import GooglePlaces
struct WalkPathItem:Identifiable{
    var id:String = UUID().uuidString
    var idx:Int = 0
    let location:CLLocation
    var smallPictureUrl:String? = nil
    var tx:Double = 0
    var ty:Double = 0
}
struct WalkPictureItem:Identifiable{
    var id:String = UUID().uuidString
    let location:CLLocation
    var pictureId:Int? = nil
    var pictureUrl:String? = nil
    var smallPictureUrl:String? = nil
    var isExpose:Bool = false
}

class WalkPath:PageProtocol{
    let id:String = UUID().uuidString
    private(set) var paths:[WalkPathItem] = []
    private(set) var pictures:[WalkPictureItem] = []
    private(set) var picture:WalkPictureItem? = nil
    @discardableResult
    func setData(_ datas:[WalkLocationData]) -> WalkPath?{
        
        var minX:Double = 180
        var maxX:Double = -180
        var minY:Double = 90
        var maxY:Double = -90
        var locations:[WalkPathItem] = []
        var idx:Int = 0
        datas.forEach{ data in
            guard let originlng = data.lng else {return}
            guard let originlat = data.lat else {return}
            var lat = originlat
            var lng = originlng
            if SystemEnvironment.isTestMode {
                let randX = Double.random(in: -0.003...0.003)
                let randY = Double.random(in: -0.003...0.003)
                lat = originlat + randX
                lng = originlng + randY
            }
            minX = min(minX, lng)
            maxX = max(maxX, lng)
            minY = min(minY, lat)
            maxY = max(maxY, lat)
            if let id = data.pictureId {
                self.pictures.append(.init(
                    location: CLLocation(latitude: lat, longitude: lng),
                    pictureId: id,
                    pictureUrl: data.pictureUrl,
                    smallPictureUrl: data.smallPictureUrl,
                    isExpose: data.isExpose ?? false
                ))
            }
            locations.append(WalkPathItem(idx:idx, location:CLLocation(latitude: lat, longitude: lng), smallPictureUrl: data.smallPictureUrl))
            idx += 1
            
        }
        
        self.picture = self.pictures.last
        let diffX:Double = abs(minX-maxX)
        let diffY:Double = abs(minY-maxY)
        let range:Double = max( diffX, diffY )
        if range <= 0 {return self}
        let modifyX:Double = (range - diffX) / 2
        let modifyY:Double = (range - diffY) / 2
        
        minX = minX - modifyX
        maxX = maxX + modifyX
        minY = minY - modifyY
        maxY = maxY + modifyY
        self.paths = locations.map{ loc in
            let tx = (loc.location.coordinate.longitude - minX)/range
            let ty = (loc.location.coordinate.latitude - minY)/range
            return .init(idx:loc.idx, location: loc.location, smallPictureUrl: loc.smallPictureUrl, tx: tx, ty: ty)
        }
        return self
    }
}



