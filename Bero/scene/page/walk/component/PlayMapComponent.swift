import Foundation
import SwiftUI
import GoogleMaps
import GooglePlaces
import QuartzCore

extension PlayMap {
    func getMe(_ loc:CLLocation) -> GMSMarker {
        let icon = self.meIcon
        let user = self.dataProvider.user
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude)
        marker.title = "Me"
        let pets = user.pets.filter{$0.isWith}
        let petNames = pets.reduce("", {$0+", "+($1.name ?? "")}).dropFirst()
        marker.snippet = "with " + petNames
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.18)
        marker.iconView = icon
        marker.zIndex = 999
        return marker
    }
    
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
        marker.title = data.user?.representativePet?.name ?? "User"
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
        marker.zIndex = 300
        if let count = data.count {
            marker.snippet = "+ " + count.description
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
        marker.zIndex = data.isCompleted ? 110 : 210
        return marker
    }
    
    func getPlaceMarker(_ data:Place) -> GMSMarker{
        guard let loc = data.location else { return GMSMarker() }
        guard let type = data.sortType else { return GMSMarker() }
        let marker = GMSMarker()
        let latitude = loc.coordinate.latitude
        let longitude = loc.coordinate.longitude
        marker.position = CLLocationCoordinate2D(
            latitude: latitude ,
            longitude: longitude
        )
        marker.userData = data
        marker.title = data.name ?? "Place"
        
        let icon = UIImage(named: data.isMark ? type.iconMark : type.icon)
        
        let image = UIImageView(image: icon)
        marker.iconView = image
        marker.groundAnchor = CGPoint(x: 0.52, y: 0.5)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.18)
        if let count = data.count  {
            marker.snippet = "+ " + count.description
        } else {
            marker.snippet = String.pageText.walkMapMarkText.replace(data.visitors.count.description)
        }
       
        marker.zIndex = data.isMark ?  100 : 200
        return marker
    }
   
}


