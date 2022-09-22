import Foundation
import SwiftUI
import GoogleMaps
import GooglePlaces
import QuartzCore

extension PlayMap {
    
    
    
    func getRoutes(_ route:Route, color:Color) -> [GMSPolyline] {
        let lines =  route.polyLines.map{ self.getRoute($0, color: color) }
        return lines
    }
    
    func getRoute(_ polyLine:String, color:Color) -> GMSPolyline {
        let line = GMSPolyline()
        line.strokeColor = color.uiColor()
        line.strokeWidth = Dimen.line.medium
        line.title = "Route"
        line.path = GMSPath.init(fromEncodedPath: polyLine)
        line.zIndex = 888
    
        return line
    }
    
    func getUserMarker(_ data:Mission) -> GMSMarker{
        guard let loc = data.destination else { return GMSMarker() }
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: loc.coordinate.latitude ,
            longitude: loc.coordinate.longitude
        )
        /*
        var child = UIHostingController(rootView: ProfileImage())
         let icon = UIImage(named: Asset.map.pinUser)?.withRenderingMode(.alwaysTemplate)
         let image = UIImageView(image: icon)
         image.tintColor = Color.brand.thirdly.uiColor()
        */
        
        
        marker.userData = data
        marker.title = data.user?.currentProfile.nickName ?? "User"
        var iconPath = ""
        let characterIdx = data.user?.characterIdx ?? 0
        switch data.user?.currentProfile.status {
        case .friend : iconPath = Asset.character.randOn[characterIdx]
        default : iconPath = Asset.character.rand[characterIdx]
        }
        let icon = UIImage(named: iconPath)
        let image = UIImageView(image: icon)
        marker.iconView = image
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.18)
        marker.zIndex = 333
        if let pets = data.user?.pets {
            let petNames = pets.reduce("", {$0+", "+($1.name ?? "")}).dropFirst()
            marker.snippet = "with " + petNames
        }
        return marker
    }
    
    func getMissionMarker(_ data:Mission) -> GMSMarker{
        guard let loc = data.destination else { return GMSMarker() }
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: loc.coordinate.latitude ,
            longitude: loc.coordinate.longitude
        )
        marker.userData = data
        marker.title = data.title ?? "Mission"
        let icon = UIImage(named: data.isCompleted ? Asset.map.pinMissionCompleted : Asset.map.pinMission)
        let image = UIImageView(image: icon)
        marker.iconView = image
        marker.groundAnchor = CGPoint(x: 0.52, y: 0.8)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.18)
        marker.snippet = data.description
        marker.zIndex = 111
        return marker
    }
    
    func getPlaceMarker(_ data:Place) -> GMSMarker{
        guard let loc = data.location else { return GMSMarker() }
        let marker = GMSMarker()
        let latitude = loc.coordinate.latitude
        let longitude = loc.coordinate.longitude
        marker.position = CLLocationCoordinate2D(
            latitude: latitude ,
            longitude: longitude
        )
        marker.userData = data
        marker.title = data.name ?? "Place"
        let icon = UIImage(named: data.isMark ? self.walkManager.placeFilter.iconComplete : self.walkManager.placeFilter.icon)
        
        let image = UIImageView(image: icon)
        marker.iconView = image
        marker.groundAnchor = CGPoint(x: 0.52, y: 0.5)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.18)
        marker.snippet = String.pageText.walkPlaceMarkText.replace(data.visitors.count.description)
        marker.zIndex = 222
        return marker
    }
   
}


