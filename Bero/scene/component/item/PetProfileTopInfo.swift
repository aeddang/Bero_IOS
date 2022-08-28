import Foundation
import SwiftUI

struct PetProfileTopInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var profile:PetProfile
    var action: (() -> Void)
    var body: some View {
        VerticalProfile(
            id: self.profile.id,
            type: .user,
            sizeType: .medium,
            isSelected: true,
            image: self.image,
            imagePath: self.imagePath,
            name: self.name,
            gender: self.gender,
            age: self.age,
            breed: self.breed,
            description: self.description,
            editProfile: self.profile.isMypet ? self.action : nil
        )
        .onReceive(self.profile.$name){value in
            self.name = value
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
        .onReceive(self.profile.$breed){value in
            self.breed = value
        }
        .onReceive(self.profile.$introduction){value in
            self.description = value
        }
        
    }
    @State var name:String? = nil
    @State var description:String? = nil
    @State var gender:Gender? = nil
    @State var age:String? = nil
    @State var breed:String? = nil
    @State var lv:Int? = nil
    @State var imagePath:String? = nil
    @State var image:UIImage? = nil
}


