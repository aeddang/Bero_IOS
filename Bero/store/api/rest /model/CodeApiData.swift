//
//  CodeApiData.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/17.
//

import Foundation

struct CodeData : Decodable {
    private(set) var category: String? = nil
    private(set) var id: Int? = nil
    private(set) var value: String? = nil
}
