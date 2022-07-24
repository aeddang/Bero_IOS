//
//  VisionApiData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/17.
//

import Foundation

struct DetectData : Decodable {
    private(set) var isDetected: Bool? = nil
    private(set) var pictureUrl: String? = nil
}

