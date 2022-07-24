//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps
import GooglePlaces
import QuartzCore

enum PlayMapUiEvent {
    case setupMission(Mission), me(CLLocation, rotate:Double? = nil), completeStep(Int)
}
class PlayMapModel:MapModel{
    @Published var playEvent:PlayMapUiEvent? = nil{
        didSet{
            if playEvent != nil { self.playEvent = nil }
        }
    }
}

extension PlayMap {
    static let uiHeight:CGFloat = 130
    static let zoomRatio:Float = 15.0
    static let zoomCloseup:Float = 16.0
    static let mapMoveDuration:Double = 1.0
    
    static let mapMoveAngle:Double = 30
}

struct PlayMap: PageView {
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
   
    @Binding var isFollowMe:Bool
    @Binding var isForceMove:Bool
    @State var wayPoints:[MapMarker] = []
    
    var bottomMargin:CGFloat = 0
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            CPGoogleMap(
                viewModel: self.viewModel,
                pageObservable: self.pageObservable)
            Button(action: {
                self.isFollowMe.toggle()
                self.viewModel.angle = self.isFollowMe ? Self.mapMoveAngle : 0
                if let loc = self.location {
                    self.moveMe(loc: loc)
                }
                
            }) {
                Image( Asset.icon.map )
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.isFollowMe ? Color.brand.secondary : Color.app.grey100)
                    .frame(width: Dimen.icon.thin,
                           height: Dimen.icon.thin)
                    .padding(.all, Dimen.margin.tiny)
                    .background(Color.app.white)
                    .clipShape(Circle())
            }
            .padding(.trailing, Dimen.margin.regular)
            .padding(.bottom, Dimen.margin.medium + self.bottomMargin)
        }
        .onReceive(self.viewModel.$playEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .setupMission(let mission) :
                //self.playSetup(mission: mission)
                break
            case .me(let loc, let rote):
                self.moveMe(loc: loc, rotation:rote)
            case .completeStep(let idx):
                self.completedStep(idx)
            }
            
        }
        
        .onAppear{
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear(){
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }//body
   
    @State var rotation:Double? = 270
    @State var location:CLLocation? = nil
  
    private func getStartMarker(_ start:GMSPlace) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: start.coordinate.latitude,
            longitude: start.coordinate.longitude)
        marker.title = "Start"
        marker.icon = UIImage(named: Asset.icon.beenhere)
        marker.snippet = start.name
        return marker
    }
    
    private func getWaypointMarker(_ point:GMSPlace, idx:Int) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: point.coordinate.latitude,
            longitude: point.coordinate.longitude)
        marker.title = "Point"+(idx+1).description
        marker.icon = UIImage(named: Asset.icon.beenhere)
        marker.snippet = point.name
        return marker
    }
    
    private func getDestinationMarker(_ destination:GMSPlace) -> GMSMarker{
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: destination.coordinate.latitude,
            longitude: destination.coordinate.longitude)
        marker.title = "Goal"
        marker.icon = UIImage(named: Asset.icon.beenhere)
        marker.snippet = destination.name
        return marker
    }
    
    /*
    private func playSetup(mission:Mission){
        var markers:[MapMarker] = []
        if let start = mission.start {
            markers.append(MapMarker(id:"start" , marker:self.getStartMarker(start)))
        }
        zip(mission.waypoints, 0..<mission.waypoints.count).forEach{ point, idx in
            markers.append(MapMarker(id:"waypoint" + idx.description , marker:self.getWaypointMarker(point, idx: idx)))
        }
        
        if let destination = mission.destination {
            markers.append(MapMarker(id:"destination" , marker:self.getDestinationMarker(destination)))
            
        }
        self.wayPoints = markers
        self.viewModel.uiEvent = .addMarkers(markers)
    }*/
    
    
    private func moveMe(loc:CLLocation, rotation:Double? = nil){
        self.location = loc
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude)
        marker.title = "Me"
        let icon = UIImage(named: self.isFollowMe ? Asset.icon.my_location : Asset.icon.my_location)!
        let imgv = UIImageView(image: icon)
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.iconView = imgv
    
        self.viewModel.uiEvent = .me( MapMarker(
            id: "me",
            marker:  marker,
            rotation: rotation ?? self.rotation,
            isRotationMap: self.isFollowMe
            
        )  , follow:self.isFollowMe ? loc : nil )
        
    }
    private func completedStep(_ step:Int){
        let marker = self.wayPoints[step].marker
        if step == self.wayPoints.count-1 {
            marker.icon = UIImage(named: Asset.icon.beenhere)
        } else {
            marker.icon = UIImage(named: Asset.icon.beenhere)
            marker.snippet = "completed"
        }
        
       
    }
}


