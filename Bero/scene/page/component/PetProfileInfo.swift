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
                image: self.image,
                imagePath: self.profile.imagePath,
                name: self.name,
                gender: self.gender,
                age: self.age,
                isSelected: false,
                action: self.action
            )
            .onReceive(self.profile.$name){value in
                self.name = value
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
    @State var name:String? = nil
    @State var gender:Gender? = nil
    @State var age:String? = nil
    @State var image:UIImage? = nil
}


