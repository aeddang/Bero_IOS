import Foundation
import SwiftUI

struct PetProfileInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:PetProfile
    var sizeType:HorizontalProfile.SizeType = .big
    var action: (() -> Void) 
    var body: some View {
        Button(action: {
            self.action()
        }) {
            PetProfileBody(
                profile: self.profile,
                sizeType: self.sizeType)
        }
    }
}

struct PetProfileEditable: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:PetProfile
    var sizeType:HorizontalProfile.SizeType = .small
    var funcType:HorizontalProfile.FuncType = .delete
    var action: (() -> Void)
    var body: some View {
        PetProfileBody(
            profile: self.profile,
            sizeType: self.sizeType,
            funcType:self.funcType,
            action: self.action
        )
    }
}

struct PetProfileEmpty: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var description:String? = String.pageText.addDogEmpty
    var action: (() -> Void)
    var body: some View {
        HorizontalProfile(
            id: "",
            type: .pet,
            sizeType: .small,
            description:self.description,
            isEmpty: true,
            action: { _ in self.action() }
        )
        .onTapGesture {
            self.action()
        }
    }
}


struct PetProfileBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:PetProfile
    var sizeType:HorizontalProfile.SizeType = .big
    var funcType:HorizontalProfile.FuncType? = nil
    var action: (() -> Void)? = nil
    var body: some View {
        HorizontalProfile(
            id: self.profile.id,
            type: .pet,
            sizeType: self.sizeType,
            funcType: self.funcType,
            image: self.image,
            imagePath: self.imagePath,
            name: self.name,
            gender: self.gender,
            age: self.age,
            breed: self.breed,
            isSelected: false,
            action: { _ in self.action?() }
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
    @State var name:String? = nil
    @State var gender:Gender? = nil
    @State var age:String? = nil
    @State var breed:String? = nil
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil
}
