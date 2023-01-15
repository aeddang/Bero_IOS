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
        marker.title = user.representativePet?.name ?? "Me"
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.18)
        marker.iconView = icon
        marker.zIndex = 700
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
        line.zIndex = 800
        return line
    }
    
    
    func getCircle(data:MapUserData) -> GMSCircle{
        guard let loc = data.location else { return GMSCircle() }
        let circleCenter = CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        let radius:Double = Double(min(max(100, data.count * 20), 1000))
        let circle = GMSCircle(position: circleCenter, radius: radius)
        circle.fillColor = data.color.uiColor().withAlphaComponent(0.5)
        
        circle.title = data.count.description + (data.title ?? "")
        circle.strokeWidth = 0
        
        return circle
    }
    
    func getUserMarker(_ data:Mission) -> GMSMarker{
        guard let loc = data.location else { return GMSMarker() }
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: loc.coordinate.latitude ,
            longitude: loc.coordinate.longitude
        )
        
        marker.userData = data
        
        if data.isGroup {
            marker.title = data.count.description + " " + (data.title ?? "")
            marker.zIndex = 900
            return marker
        }
        if let path = data.pictureUrl {
            marker.title = data.title ?? "User"
            let scale:CGFloat = UIScreen.main.scale
            let size = Dimen.profile.regular
            if let prevImg =  data.previewImg {
                onMarkerImage(uiImage: prevImg)
            } else {
                let loader = ImageLoader()
                loader.$event.sink(receiveValue: { evt in
                    guard let  evt = evt else { return }
                    switch evt {
                    case .reset :break
                    case .complete(let img) :
                        DispatchQueue.global(qos:.background).async {
                            
                            let uiImage = img.normalized().centerCrop()
                                .resize(to: CGSize(
                                    width: size/scale ,
                                    height: size/scale ))
                            data.previewImg = uiImage
                            DispatchQueue.main.async {
                                onMarkerImage(uiImage: uiImage)
                            }
                        }
                        
                    case .error :break
                    }
                }).store(in: &anyCancellable)
                loader.load(url: path)
            }
            
            func onMarkerImage(uiImage:UIImage){
                marker.icon = uiImage.maskRoundedImage(
                    radius: size/2,
                    borderColor:Color.brand.primary,
                    borderWidth:Dimen.stroke.regular)
            }
            
        } else {
            let icon = UIImage(named: Asset.image.profile_dog_default)
            let image = UIImageView(image: icon)
            marker.iconView = image
        }
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.3)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.18)
        marker.zIndex = 300
        return marker
    }
    
    func getMissionMarker(_ data:Mission) -> GMSMarker{
        guard let loc = data.location else { return GMSMarker() }
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
        
        if data.isGroup {
            marker.title = data.count.description + " " + (data.title ?? "")
            marker.zIndex = 900
            return marker
        }
        let icon = UIImage(named: data.isMark ? type.iconMark : type.icon)
        let image = UIImageView(image: icon)
        marker.iconView = image
        marker.title = data.title ?? "Place"
        marker.snippet = String.pageText.walkMapMarkText.replace(data.visitors.count.description)
        marker.groundAnchor = CGPoint(x: 0.52, y: 0.5)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.18)
        marker.zIndex = data.isMark ?  100 : 200
        return marker
    }
   
}


