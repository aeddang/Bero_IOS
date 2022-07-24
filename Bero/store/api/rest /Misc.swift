//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI
import CoreLocation
class MiscApi :Rest{
    func getWeather(location:CLLocation, completion: @escaping (ApiContentResponse<WeatherCityData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["lat"] = location.coordinate.latitude.description
        params["lng"] = location.coordinate.longitude.description
        
        fetch(route: WeatherApiRoute( query:params), completion: completion, error:error)
    }
    func getWeather(id:String, action:ApiAction = .cities, completion: @escaping (ApiContentResponse<WeatherCityData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: WeatherApiRoute(action:action, commandId: id), completion: completion, error:error)
    }
}

struct WeatherApiRoute : ApiRoute{
    var method:HTTPMethod = .get
    var command: String = "misc/weather"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

