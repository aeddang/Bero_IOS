//
//  CustomCamera.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/22.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps
struct CPGoogleMap {
    @ObservedObject var viewModel:MapModel
    @ObservedObject var pageObservable:PageObservable
    func makeCoordinator() -> Coordinator { return Coordinator() }
    class Coordinator:NSObject, PageProtocol {
    
    }
}


extension CPGoogleMap: UIViewControllerRepresentable, PageProtocol {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CPGoogleMap>) -> UIViewController {
        let mapController = CustomGoogleMapController(viewModel: self.viewModel)
        //mapController.delegate = context.coordinator
        return mapController
        
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CPGoogleMap>) {
       if viewModel.status != .update { return }
        guard let evt = viewModel.uiEvent else { return }
        guard let map = uiViewController as? CustomGoogleMapController else { return }
        DispatchQueue.main.async {
            switch evt {
            case .zip(let evts) : evts.forEach{self.updateExcute(map: map, evt: $0)}
            default : self.updateExcute(map: map, evt: evt)
            }
        }
    }
    
    private func updateExcute(map:CustomGoogleMapController, evt:MapUiEvent){
        viewModel.uiEvent = nil
        switch evt {
        case .addMarker(let marker):
            map.addMarker(marker)
        case .addMarkers(let markers):
            map.addMarker(markers)
        case .addRoute(let route):
            map.addRoute(route)
        case .addRoutes(let routes):
            map.addRoute(routes)
        case .addCircle(let circle):
            map.addCircle(circle)
        case .addCircles(let circles):
            map.addCircle(circles)
        case .me(let marker, let loc):
            map.me(marker)
            if let loc = loc {
                map.move(loc)
            }
        case .clearAllRoute : map.clearAllRoute()
        case .clearAll(let clears, let exception) : map.clearAll(clears, exception:exception)
        case .clear(let id) : map.clear(id: id)
        case .move(let loc, let rotate, let zoom, let angle, let duration):
            map.move(loc, rotate:rotate, zoom:zoom, angle:angle, duration:duration)
        default :  break
        }
    }
}



open class CustomGoogleMapController: UIViewController, GMSMapViewDelegate {
    @ObservedObject var viewModel:MapModel
    private var markers:[String: GMSMarker] = [:]
    private var circles:[String: GMSCircle] = [:]
    private var routes:[String: GMSPolyline] = [:]
    init(viewModel:MapModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var mapView: GMSMapView? = nil
    private var camera: GMSCameraPosition? = nil
    private var mapRotate:Double = 0
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(
            withLatitude: self.viewModel.startLocation.coordinate.latitude,
            longitude: self.viewModel.startLocation.coordinate.longitude,
            zoom: self.viewModel.zoom)
        let mapID = GMSMapID(identifier: "c7dec7b5fab604aa")
        //let mapView = GMSMapView.init(frame: self.view.bounds, camera: camera)
        let mapView = GMSMapView.init(frame: self.view.bounds, mapID: mapID, camera: camera)
     
        self.view.addSubview(mapView)
        mapView.delegate = self
        self.mapView = mapView
        self.camera = camera
        // Creates a marker in the center of the map.
    }
    
    fileprivate func me(_ marker:MapMarker ){
        self.addMarker(marker)
        //ComponentLog.d("me " + loc.debugDescription , tag: "CPGoogleMap")
    }
    fileprivate func move(_ loc:CLLocation, rotate:Double? = nil, zoom:Float? = nil, angle:Double? = nil, duration:Double? = nil){
        if let rotate {
            self.mapRotate = rotate
        }
        if let duration = duration {
            CATransaction.begin()
            CATransaction.setValue(duration, forKey: kCATransactionAnimationDuration)
            let camera = GMSCameraPosition(
                target: loc.coordinate,
                zoom: zoom ?? self.viewModel.zoom,
                bearing: self.mapRotate,
                viewingAngle: angle ?? self.viewModel.angle
            )
            self.mapView?.animate(to: camera)
            CATransaction.commit()
        }else{
            mapView?.camera = GMSCameraPosition(
                target: loc.coordinate,
                zoom: zoom ?? self.viewModel.zoom,
                bearing: self.mapRotate,
                viewingAngle: angle ?? self.viewModel.angle
            )
        }
       
    }
    
    fileprivate func addMarker(_ marker:MapMarker ){
        
        if let prevMarker = self.markers[marker.id] {
            var mapRotete:Double = 0
            if marker.isRotationMap {
                let targetPoint = CGPoint(x:  marker.marker.position.latitude, y:  marker.marker.position.longitude)
                let mePoint = CGPoint(x: prevMarker.position.latitude, y: prevMarker.position.longitude)
                let rt = mePoint.getAngleBetweenPoints(target: targetPoint)
                mapRotete = rt
                self.mapRotate = rt
            }
            
            if prevMarker.iconView != marker.marker.iconView {
                prevMarker.iconView = marker.marker.iconView
            }
            prevMarker.title = marker.marker.title
            prevMarker.snippet = marker.marker.snippet
            prevMarker.position = marker.marker.position
            if let rt = marker.rotation {
                prevMarker.rotation = rt - mapRotete
            } else {
                prevMarker.rotation = 0
            }
            
        } else {
            self.markers[marker.id] = marker.marker
            marker.marker.map = mapView
        }
    }
    fileprivate func addMarker(_ markers:[MapMarker]){
        markers.forEach{
            self.addMarker($0)
        }
    }
    
    fileprivate func addRoute(_ route:MapRoute ){
        if let prevRoute = self.routes[route.id] {
            prevRoute.title = route.line.title
        } else {
            self.routes[route.id] = route.line
            route.line.map = mapView
        }
    }
    
    fileprivate func addRoute(_ routes:[MapRoute] ){
        routes.forEach{
            self.addRoute($0)
        }
    }
    
    fileprivate func addCircle(_ circle:MapCircle ){
        if let prevCircle = self.circles[circle.id] {
            prevCircle.radius = circle.marker.radius
            prevCircle.fillColor = circle.marker.fillColor
            prevCircle.title = circle.marker.title
        } else {
            self.circles[circle.id] = circle.marker
            circle.marker.map = mapView
        }
    }
    
    fileprivate func addCircle(_ circles:[MapCircle] ){
        circles.forEach{
            self.addCircle($0)
        }
    }
    
    fileprivate func clearAllRoute(){
        self.routes.forEach{$0.value.map = nil}
        self.routes = [:]
    }
    
    fileprivate func clear(id:String){
        if let route = self.routes[id] {
            route.map = nil
            self.routes[id] = nil
        }
        if let marker = self.markers[id] {
            marker.map = nil
            self.markers[id] = nil
        }
        
        if let circle = self.circles[id] {
            circle.map = nil
            self.circles[id] = nil
        }
    }
    
    fileprivate func clearAll(_ clears:[String]? = nil, exception:[String]? = nil){
        if let clears = clears {
            clears.forEach{ self.clear(id: $0) }
        } else {
            var newMarkers:[String: GMSMarker] = [:]
            var newCircles:[String: GMSCircle] = [:]
            var newRoutes:[String: GMSPolyline] = [:]
        
            self.routes.forEach{ route in
                let key = route.key
                if exception?.first(where: {$0 == key}) != nil {
                    newRoutes[key] = route.value
                } else {
                    route.value.map = nil
                }
            }
            self.markers.forEach{marker in
                let key = marker.key
                if exception?.first(where: {$0 == key}) != nil {
                    newMarkers[key] = marker.value
                } else {
                    marker.value.map = nil
                }
            }
            self.circles.forEach{marker in
                let key = marker.key
                if exception?.first(where: {$0 == key}) != nil {
                    newCircles[key] = marker.value
                } else {
                    marker.value.map = nil
                }
            }
            self.markers = newMarkers
            self.routes = newRoutes
            self.circles = newCircles
        }
    }
    
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //ComponentLog.d("willMove gesture " + gesture.description, tag: "CustomGoogleMapController")
        self.viewModel.event = .move(isUser: gesture)
    }
    public func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        //ComponentLog.d("didChange CameraPosition", tag: "CustomGoogleMapController")
        self.viewModel.position = position
    }
    
    public func mapView(_ mapView: GMSMapView, didTapAt coordinate:CLLocationCoordinate2D) {
        self.viewModel.event = .tab(.init(latitude: coordinate.latitude, longitude: coordinate.longitude)) 
    }
    
    public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let userData:MapUserData = marker.userData as? MapUserData else { return false }
        userData.isSelected.toggle()
        if userData.isSelected {
            self.viewModel.event = .tabMarker(marker)
        } else {
            self.viewModel.event = .tabOffMarker(marker)
        }
        return false
    }
    public func mapView(_ mapView: GMSMapView, didTapInfoWindow marker: GMSMarker) -> Bool {
        //self.viewModel.event = .tabMarker(marker)
        return false // return false to display info window
    }
    public func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        guard let userData:MapUserData = marker.userData as? MapUserData else { return }
        userData.isSelected = false
        //self.viewModel.event = .tabMarker(marker)
    }
}
