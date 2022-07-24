//
//  WeatherApiData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/02/05.
//

import Foundation

struct WeatherCityData : Decodable {
    private(set) var cityName: String? = nil
    private(set) var temp: Double? = nil
    private(set) var desc: String? = nil
    private(set) var iconId: String? = nil
}

