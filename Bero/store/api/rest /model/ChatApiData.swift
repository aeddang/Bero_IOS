//
//  ChatApiData.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/09/11.
//

import Foundation
struct ChatRoomData : Decodable {
    private(set) var chatRoomId: Int? = nil
    private(set) var title: String? = nil
    private(set) var desc: String? = nil
    private(set) var createdAt: String? = nil
    private(set) var updatedAt: String? = nil
    private(set) var unreadCnt:Int? = nil
    private(set) var sender: String? = nil
    private(set) var receiver: String? = nil
    private(set) var receiverProfile: String? = nil
}

struct ChatsData : Decodable {
    private(set) var sendUser: UserData? = nil
    private(set) var sendPets: [PetData]? = nil
    private(set) var receiveUser: UserData? = nil
    private(set) var receivePets: [PetData]? = nil
    private(set) var chats:[ChatData]? = nil
}

struct ChatData : Decodable {
    private(set) var chatId: Int? = nil
    private(set) var title: String? = nil
    private(set) var contents: String? = nil
    private(set) var createdAt: String? = nil
    private(set) var sender: String? = nil
    private(set) var receiver: String? = nil
    private(set) var isRead: Bool? = nil
    private(set) var isDeleted: Bool? = nil
}
