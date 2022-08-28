import Foundation
import SwiftUI

struct PetProfileInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:PetProfile
    var action: (() -> Void) 
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HorizontalProfile(
                id: self.profile.id,
                type: .pet,
                sizeType: .big,
                image: self.image,
                imagePath: self.imagePath,
                name: self.name,
                gender: self.gender,
                age: self.age,
                breed: self.breed,
                isSelected: false
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
        }
    }
    @State var name:String? = nil
    @State var gender:Gender? = nil
    @State var age:String? = nil
    @State var breed:String? = nil
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil
}


