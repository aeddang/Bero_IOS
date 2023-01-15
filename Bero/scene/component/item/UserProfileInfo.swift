import Foundation
import SwiftUI

struct UserProfileInfo: PageComponent{
    var profile:UserProfile
    var sizeType:HorizontalProfile.SizeType = .small
    var action: (() -> Void)? = nil
    var body: some View {
        if let action = self.action {
            Button(action: {
                action()
            }) {
                UserProfileInfoBody(
                    profile: self.profile,
                    sizeType: self.sizeType
                )
            }
        } else {
            UserProfileInfoBody(
                profile: self.profile,
                sizeType: self.sizeType
            )
        }
    }
}

struct UserProfileInfoBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:UserProfile
    var sizeType:HorizontalProfile.SizeType = .small

    var body: some View {
        HorizontalProfile(
            id: self.profile.id,
            type: .user,
            sizeType: self.sizeType,
            image: self.image,
            imagePath: self.imagePath,
            name: self.nickName,
            gender: self.gender,
            age: self.age,
            isSelected: false
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
    }
    @State var nickName:String? = nil
    @State var gender:Gender? = nil
    @State var age:String? = nil
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil
}


