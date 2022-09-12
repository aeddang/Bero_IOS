//
//  ChatApiData.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/09/11.
//

import Foundation
struct ChatData : Decodable {
    private(set) var chatId: Int? = nil
    private(set) var title: String? = nil
    private(set) var contents: String? = nil
    private(set) var createdAt: String? = nil
    private(set) var sender: String? = nil
    private(set) var receiver: String? = nil
    private(set) var isRead: Bool? = nil
    private(set) var userName: String? = nil
    private(set) var senderUser:UserData? = nil
    private(set) var senderPets: [PetData]? = nil
}
