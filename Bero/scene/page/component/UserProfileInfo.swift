import Foundation
import SwiftUI

struct UserProfileInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:UserProfile
    var action: (() -> Void)
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HorizontalProfile(
                id: self.profile.id,
                type: .user,
                image: self.image,
                imagePath: self.profile.imagePath,
                name: self.nickName,
                gender: self.gender,
                age: self.age,
                isSelected: false,
                action: self.action
            )
            .onReceive(self.profile.$nickName){value in
                self.nickName = value
            }
            .onReceive(self.profile.$image){value in
                self.image = value
            }
            .onReceive(self.profile.$gender){value in
                self.gender = value
            }
            .onReceive(self.profile.$birth){value in
                self.age = value?.toAge()
            }
        }
    }
    @State var nickName:String? = nil
    @State var gender:Gender? = nil
    @State var age:String? = nil
    @State var image:UIImage? = nil
}


