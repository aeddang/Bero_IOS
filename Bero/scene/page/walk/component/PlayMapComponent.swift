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
        return line
    }
    
    func getUserMarker(_ data:Mission) -> GMSMarker{
        guard let loc = data.destination else { return GMSMarker() }
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: loc.coordinate.latitude ,
            longitude: loc.coordinate.longitude
        )
        marker.userData = data
        marker.title = data.user?.currentProfile.nickName ?? "User"
        let icon = UIImage(named: Asset.icon.dog_friends)?.withRenderingMode(.alwaysTemplate)
        let image = UIImageView(image: icon)
        image.tintColor = Color.brand.thirdly.uiColor()
        marker.iconView = image
        marker.snippet = data.user?.pets.first?.name
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
        let icon = UIImage(named: data.isStart ? Asset.icon.paw : Asset.icon.goal)?.withRenderingMode(.alwaysTemplate)
        let image = UIImageView(image: icon)
        image.tintColor = data.isStart ? Color.brand.primary.uiColor(): Color.brand.secondary.uiColor()
        marker.iconView = image
        marker.snippet = data.description
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
        let icon = UIImage(named: Asset.icon.beenhere)?.withRenderingMode(.alwaysTemplate)
        let image = UIImageView(image: icon)
        image.tintColor = Color.brand.thirdly.uiColor()
        marker.iconView = image
        marker.snippet = data.visitors.first?.userName
        return marker
    }
   
}


