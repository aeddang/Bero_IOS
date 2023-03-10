import Foundation
import SwiftUI
import GoogleMaps
import GooglePlaces
import QuartzCore

extension PlayMap {
    func getIcon(img:String)->UIImageView {
        let icon = UIImage(named: img)
        let imgv = UIImageView(image: icon)
        return imgv
    }
    
    
    func getMe(_ loc:CLLocation) -> GMSMarker {
        let icon = self.isWalk
        ? self.isFollowMe ? self.myWalkingOn : self.myWalkingOff
        : self.isFollowMe ? self.myLocationOn : self.myLocationOff
        
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
        marker.appearAnimation = .fadeIn
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
        circle.fillColor = data.color.uiColor().withAlphaComponent(0.3)
        
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
        marker.appearAnimation = .fadeIn
        if data.isGroup {
            let rand = Int.random(in: 0...(Asset.map.pinUsers.count-1))
            marker.iconView = self.getIcon(img: Asset.map.pinUsers[rand])
            marker.title = data.count.description + " " + (data.title ?? "")
            marker.zIndex = 900
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.1)
            return marker
        }
        if let path = data.pictureUrl {
            marker.title = data.title ?? "User"
            let size = Dimen.profile.lightExtra
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
                                    width: size,
                                    height: size))
                            data.previewImg = uiImage
                            DispatchQueue.main.async {
                                onMarkerImage(uiImage: uiImage)
                            }
                        }
                        
                    case .error :
                        marker.iconView = self.getIcon(img: Asset.map.pinUser)
                    }
                }).store(in: &anyCancellable)
                loader.load(url: path)
            }
            
            func onMarkerImage(uiImage:UIImage){
                let scale:CGFloat = UIScreen.main.scale
                let icon = uiImage.maskRoundedImage(
                    radius: size*scale/2,
                    borderColor:data.isFriend ? Color.brand.primary : Color.app.white,
                    borderWidth:Dimen.stroke.regular*scale)
                
                let image = UIImageView(image: icon)
                image.frame = .init(x: 0, y: 0, width: size, height: size)
                marker.iconView = image
            }
            
        } else {
            marker.iconView = self.getIcon(img: Asset.map.pinUser)
        }
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.3)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.16)
        marker.zIndex = 300
        return marker
    }
    
    func getMissionMarker(_ data:Mission) -> GMSMarker{
        guard let loc = data.location else { return GMSMarker() }
        let marker = GMSMarker()
        marker.appearAnimation = .fadeIn
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
        marker.appearAnimation = .fadeIn
        let latitude = loc.coordinate.latitude
        let longitude = loc.coordinate.longitude
        marker.position = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
        marker.userData = data
        
        if data.isGroup {
            marker.iconView = self.getIcon(img: Asset.map.pinMission)
            marker.title = data.count.description + " " + (data.title ?? "")
            marker.zIndex = 900
            return marker
        }
        let icon = UIImage(named: data.isMark ? type.iconMark : type.icon)
        let image = UIImageView(image: icon)
        let view = MapPlaceView(frame:.infinite)
        marker.iconView = image
        marker.title = data.title ?? "Place"
        marker.groundAnchor = CGPoint(x: 0.52, y: 0.5)
        marker.zIndex = data.isMark ?  100 : 200
        marker.tracksInfoWindowChanges = true
        return marker
    }
   
}


