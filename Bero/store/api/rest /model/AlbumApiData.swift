//
//  AlbumApiData.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/18.
//

import Foundation

struct PictureData : Decodable {
    private(set) var pictureId: Int? = nil
    private(set) var pictureType: String? = nil
    private(set) var ownerId: String? = nil
    private(set) var pictureUrl: String? = nil
    private(set) var smallPictureUrl: String? = nil
    private(set) var thumbsupCount: Double? = nil
    private(set) var isChecked: Bool? = nil
    private(set) var createdAt: String? = nil
}

struct PictureUpdateData : Decodable {
    private(set) var id: String? = nil
    private(set) var isChecked: Bool? = nil
}


