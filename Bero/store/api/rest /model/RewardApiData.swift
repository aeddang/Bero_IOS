//
//  RewardApiData.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/09/06.
//

import Foundation
struct RewardHistoryData : Decodable {
    private(set) var expType: String? = nil
    private(set) var exp: Double? = nil
    private(set) var createdAt: String? = nil
    private(set) var userId: String? = nil
}

