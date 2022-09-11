//
//  MissionApiData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/03.
//

import Foundation
struct MissionData : Decodable {
    private(set) var missionId: Int? = nil
    private(set) var missionCategory: String? = nil
    private(set) var missionType: String? = nil
    private(set) var difficulty: String? = nil
    private(set) var title: String? = nil
    private(set) var description: String? = nil
    private(set) var createdAt: String? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var duration: Double? = nil
    private(set) var distance: Double? = nil
    private(set) var point: Int? = nil
    private(set) var exp: Int? = nil
    private(set) var user: UserData? = nil
    private(set) var geos: [GeoData]? = nil
    private(set) var pets: [PetData]? = nil
    private(set) var place:MissionPlace? = nil
}


struct MissionSummary : Decodable {
    private(set) var totalDuration: Double? = nil
    private(set) var totalDistance: Double? = nil
    private(set) var weeklyReport: MissionReport? = nil
    private(set) var monthlyReport: MissionReport? = nil
}

struct MissionReport : Decodable {
    private(set) var totalMissionCount: Double? = nil
    private(set) var avgMissionCount: Double? = nil
    private(set) var missionTimes: [MissionTime]? = nil
}

    
struct MissionTime : Decodable {
    private(set) var d: String? = nil
    private(set) var v: Double? = nil
}


struct MissionPlace : Decodable {
    private(set) var geometry: GeometryData? = nil
    private(set) var icon: String? = nil
    private(set) var icon_background_color: String? = nil
    private(set) var name: String? = nil
    //private(set) var photos: String? = nil
    private(set) var place_id: String? = nil
    private(set) var scope: String? = nil
    private(set) var types: [String]? = nil
    private(set) var vicinity: String? = nil
}

struct MissionRoute : Decodable {
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


