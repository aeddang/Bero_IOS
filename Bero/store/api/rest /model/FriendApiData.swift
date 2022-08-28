

import Foundation
struct FriendData : Decodable {
    private(set) var userId: String? = nil
    private(set) var refUserId: String? = nil
    private(set) var isAccepted: Bool? = nil
}

