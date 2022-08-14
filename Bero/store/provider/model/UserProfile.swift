import Foundation
import SwiftUI
import UIKit

struct ModifyUserProfileData {
    var image:UIImage? = nil
    var nickName:String? = nil
    var gender:Gender? = nil
    var birth:Date? = nil
    var email:String? =  nil
}

class UserProfile:ObservableObject, PageProtocol, Identifiable {
    private(set) var id:String = UUID().uuidString
    private(set) var imagePath:String? = nil
    @Published private(set) var image:UIImage? = nil
    @Published private(set) var nickName:String? = nil
    @Published private(set) var gender:Gender? = nil
    @Published private(set) var birth:Date? = nil
    @Published private(set) var email:String? =  nil
    private(set) var type:SnsType? = nil
   

    @discardableResult
    func setData(data:SnsUser) -> UserProfile{
        self.type = data.snsType
        return self
    }
    
    func setData(data:UserData){
        self.nickName = data.name
        self.email = data.email
        self.imagePath = data.pictureUrl
        self.type = SnsType.getType(code: data.providerType)
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
        return self
    }
    
    
    
}
