//
//  Route.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/15.
//

import Foundation
import GooglePlaces

class Route:PageProtocol, Identifiable{
    let id:String = UUID().uuidString
    private (set) var descriptions:[String] = []
    private (set) var durations:[Double] = []
    private (set) var distances:[Double] = []
    private (set) var waypoints:[CLLocation] = []
    
   
    private (set) var distance:Double = 0 //miter
    private (set) var duration:Double = 0 //sec
    
    @discardableResult
    func setData(_ data:MissionRoute)->Route{
        guard let leg = data.legs?.first else { return self }
        
        if let loc = leg.start_location {
            descriptions.append(leg.start_address ?? "")
            durations.append(0)
            distances.append(0)
            waypoints.append(CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0))
        }
        if let steps = leg.steps {
            steps.forEach{ leg in
                if let loc = leg.end_location {
                    descriptions.append(leg.html_instructions ?? "")
                    durations.append(leg.duration?.value ?? 0)
                    distances.append(leg.distance?.value ?? 0)
                    waypoints.append(CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0))
                }
            }
        }
        if let loc = leg.end_location {
            descriptions.append(leg.end_address ?? "")
            durations.append(0)
            distances.append(0)
            waypoints.append(CLLocation(latitude: loc.lat ?? 0, longitude: loc.lng ?? 0))
        }
        
        self.distance = leg.distance?.value ?? 0
        self.duration = leg.duration?.value ?? 0
        return self
    }
    
    
}



