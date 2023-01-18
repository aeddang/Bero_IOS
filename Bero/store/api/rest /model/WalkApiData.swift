//
//  WalkApiData.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/12/22.
//

import Foundation
struct WalkData : Decodable {
    private(set) var walkId: Int? = nil
    private(set) var createdAt: String? = nil
    private(set) var duration: Double? = nil
    private(set) var distance: Double? = nil
    private(set) var point: Int? = nil
    private(set) var exp: Double? = nil
    private(set) var user: UserData? = nil
    private(set) var geos: [GeoData]? = nil
    private(set) var pets: [PetData]? = nil
    private(set) var locations: [WalkLocationData]? = nil
}

struct WalkUserData : Decodable {
    private(set) var userId: String? = nil
    private(set) var walkId: Int? = nil
    private(set) var isFriend: Bool? = nil
    private(set) var createdAt: String? = nil
    private(set) var location: GeoData? = nil
    private(set) var pet:PetData? = nil
    
    
}

struct WalkRegistData : Decodable {
    private(set) var walkId: Int? = nil
}

struct WalkLocationData : Decodable {
    private(set) var lat:Double? = nil
    private(set) var lng:Double? = nil
    private(set) var pictureId: Int? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var smallPictureUrl: String? = nil
    private(set) var isExpose:Bool? = nil
    private(set) var createdAt: String? = nil
}

struct WalkSummary : Decodable {
    private(set) var totalDuration: Double? = nil
    private(set) var totalDistance: Double? = nil
    private(set) var weeklyReport: WalkReport? = nil
    private(set) var monthlyReport: WalkReport? = nil
}

struct WalkReport : Decodable {
    private(set) var totalCount: Double? = nil
    private(set) var avgCount: Double? = nil
    private(set) var times: [WalkTime]? = nil
}

struct WalkTime : Decodable {
    private(set) var d: String? = nil
    private(set) var v: Double? = nil
}

struct WalkRoute : Decodable {
    private(set) var legs: [RouteLeg]? = nil
}

struct RouteLeg : Decodable {
    private(set) var arrival_time: Routeinfo? = nil
    private(set) var departure_time: Routeinfo? = nil
    private(set) var distance: Routeinfo? = nil
    private(set) var duration: Routeinfo? = nil
    private(set) var end_location: GeoData? = nil
    private(set) var start_location: GeoData? = nil
    private(set) var steps: [RouteStep]? = nil
    private(set) var start_address: String? = nil
    private(set) var end_address: String? = nil
}

struct RouteStep : Decodable {
    private(set) var distance: Routeinfo? = nil
    private(set) var duration: Routeinfo? = nil
    private(set) var end_location: GeoData? = nil
    private(set) var start_location: GeoData? = nil
    private(set) var polyline: Polyline? = nil
    private(set) var html_instructions: String? = nil
}

struct Routeinfo : Decodable {
    private(set) var text: String? = nil
    private(set) var value: Double? = nil
}
struct Polyline : Decodable {
    private(set) var points: String? = nil
}

struct GeometryData : Decodable {
    private(set) var location: GeoData? = nil
    private(set) var viewport: ViewPortData? = nil
}

struct ViewPortData : Decodable {
    private(set) var northeast: GeoData? = nil
    private(set) var southwest: GeoData? = nil
}

struct GeoData : Decodable {
    private(set) var lat: Double? = nil
    private(set) var lng: Double? = nil
}
