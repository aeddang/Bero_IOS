//
//  LocationObserver.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/07.
//

import Foundation
import CoreLocation

enum LocationObserverEvent {
    case updateAuthorization(CLAuthorizationStatus), updateLocation(CLLocation)
}

struct LocationAddress {
    var street:String? = nil
    var city:String? = nil
    var state:String? = nil
    var zipCode :String? = nil
    var country :String? = nil
}


class LocationObserver: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let  locationManager = CLLocationManager()
    private(set) var isSearch:Bool = false
    private(set) var requestId:String? = nil
    private(set) var finalLocation:CLLocation? = nil
    @Published var event: LocationObserverEvent? = nil
    {
        didSet{
            if self.event == nil { return }
            self.event = nil
        }
    }
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    deinit {
        self.locationManager.delegate = nil
        if self.isSearch {
            locationManager.stopUpdatingLocation()
            self.isSearch = false
        }
    }
    
    var status:CLAuthorizationStatus {
        get{
            if #available(iOS 14.0, *){
                return self.locationManager.authorizationStatus
            } else {
                return CLLocationManager.authorizationStatus()
            }
        }
    }
    
    func requestWhenInUseAuthorization(){
        locationManager.requestWhenInUseAuthorization()
    }
    /*
    public let kCLLocationAccuracyBestForNavigation: CLLocationAccuracy
    public let kCLLocationAccuracyBest: CLLocationAccuracy
    public let kCLLocationAccuracyNearestTenMeters: CLLocationAccuracy
    public let kCLLocationAccuracyHundredMeters: CLLocationAccuracy
    public let kCLLocationAccuracyKilometer: CLLocationAccuracy
    public let kCLLocationAccuracyThreeKilometers: CLLocationAccuracy
    */
    func requestMe(_ isStart:Bool, id:String? = nil, desiredAccuracy:CLLocationAccuracy? = nil ){
        if isStart {
            if self.isSearch {
                if let loc = self.finalLocation {
                    self.event = .updateLocation(loc)
                }
                return
                
            }
            self.isSearch = true
            if let id = id { self.requestId = id }
           
            if let desiredAccuracy = desiredAccuracy {
                locationManager.desiredAccuracy = desiredAccuracy
            }
            locationManager.startUpdatingLocation()
        } else {
            if !self.isSearch { return }
            if let id = id , let prev = self.requestId{
                if id != prev { return }
            }
            self.isSearch = false
            self.requestId = nil
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.event = .updateAuthorization(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.finalLocation = location
        self.event = .updateLocation(location)
    }
    
    func convertLocationToAddress(location:CLLocation, com:@escaping (LocationAddress) -> Void) {
        self.convertLatLongToAddress(latitude:location.coordinate.latitude ,longitude:location.coordinate.longitude , com:com)
    }
    
    func convertLatLongToAddress(latitude:Double,longitude:Double, com:@escaping (LocationAddress) -> Void)  {
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var address = LocationAddress()
            
            if let placeMark = placemarks?[0] {
                // Street address
                address.street = placeMark.thoroughfare
                // City
                address.city = placeMark.locality
                // State
                address.state = placeMark.administrativeArea
                // Zip code
                address.zipCode = placeMark.postalCode
                // Country
                address.country = placeMark.country
                com(address)
            } else {
                com(address)
            }
        })
        
    }
}
