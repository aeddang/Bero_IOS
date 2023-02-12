

import Foundation
struct FriendData : Decodable {
    private(set) var userId: String? = nil
    private(set) var refUserId: String? = nil
    private(set) var isAccepted: Bool? = nil
    private(set) var createdAt: String? = nil
    private(set) var petId: Int? = nil
    private(set) var userImg: String? = nil
    private(set) var petImg: String? = nil
    private(set) var userName: String? = nil
    private(set) var petName: String? = nil
    private(set) var level: Int? = nil
}
