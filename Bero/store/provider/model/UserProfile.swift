import Foundation
import SwiftUI
import UIKit

struct ModifyUserProfileData {
    var image:UIImage? = nil
    var nickName:String? = nil
    var gender:Gender? = nil
    var birth:Date? = nil
    var email:String? =  nil
    var introduction:String? = nil
}

class UserProfile:ObservableObject, PageProtocol, Identifiable {
    private(set) var id:String = UUID().uuidString
    @Published private(set) var imagePath:String? = nil
    @Published private(set) var image:UIImage? = nil
    @Published private(set) var nickName:String? = nil
    @Published private(set) var introduction:String? = nil
    @Published private(set) var gender:Gender? = nil
    @Published private(set) var birth:Date? = nil
    @Published private(set) var email:String? =  nil
    @Published private(set) var lv:Int = 1
    private(set) var type:SnsType? = nil
    let isMine:Bool
    init(isMine:Bool = false){
        self.isMine = isMine
    }

    @discardableResult
    func setData(data:SnsUser) -> UserProfile{
        self.type = data.snsType
        return self
    }
    
    func setData(data:UserData){
        self.nickName = data.name
        self.email = data.email
        if data.pictureUrl?.isEmpty == false {
            self.imagePath = data.pictureUrl
        }
        self.type = SnsType.getType(code: data.providerType)
        if let name = data.name {
            self.introduction = String.pageText.introductionDefault.replace(name)
        }
        self.image = nil
    }
    
    @discardableResult
    func update(data:ModifyUserProfileData) -> UserProfile{
        if let value = data.image { self.image = value }
        if let value = data.nickName { self.nickName = value }
        if let value = data.gender { self.gender = value }
        if let value = data.birth { self.birth = value }
        if let value = data.email { self.email = value }
        return self
    }
    
    @discardableResult
    func update(image:UIImage?) -> UserProfile{
        self.image = image
        if image == nil {
            self.imagePath = nil
        }
        return self
    }
    
    
    
}
