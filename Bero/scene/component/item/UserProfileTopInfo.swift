import Foundation
import SwiftUI

struct UserProfileTopInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var profile:UserProfile
    var isSimple:Bool = false
    var action: (() -> Void)? = nil
    var body: some View {
        VerticalProfile(
            id: self.profile.id,
            type: .user,
            alignment: .center,//self.isSimple ? .leading : .center,
            sizeType: .medium,
            isSelected: true,
            image: self.image,
            imagePath: self.imagePath,
            lv: self.lv,
            name: self.nickName,
            gender: self.gender,
            age: self.age,
            description: self.isSimple ? nil : self.description,
            editProfile: self.profile.isMine ? self.action : nil
        )
        .onReceive(self.profile.$nickName){value in
            self.nickName = value
        }
        .onReceive(self.profile.$image){value in
            self.image = value
        }
        .onReceive(self.profile.$imagePath){value in
            self.imagePath = value
        }
        .onReceive(self.profile.$gender){value in
            self.gender = value
        }
        .onReceive(self.profile.$birth){value in
            self.age = value?.toAge()
        }
        .onReceive(self.profile.$lv){value in
            self.lv = value
        }
        .onReceive(self.profile.$introduction){value in
            self.description = value
        }
        
    }
    @State var nickName:String? = nil
    @State var description:String? = nil
    @State var gender:Gender? = nil
    @State var age:String? = nil
    @State var lv:Int? = nil
    @State var imagePath:String? = nil
    @State var image:UIImage? = nil
}


