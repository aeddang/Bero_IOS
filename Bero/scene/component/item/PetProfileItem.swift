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

struct PetProfileUser: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:PetProfile
    var friendStatus:FriendStatus? = nil
    var distance:Double? = nil
    var action: (() -> Void)
    var body: some View {
        Button(action: {
            self.action()
        }) {
            PetProfileBody(
                profile: self.profile,
                sizeType: .small,
                userId: self.profile.userId,
                friendStatus: self.friendStatus,
                distance: self.distance
            )
        }
    }
}

struct PetProfileEditable: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:PetProfile
    var sizeType:HorizontalProfile.SizeType = .small
    var funcType:HorizontalProfile.FuncType = .delete
    var isSelected:Bool = false
    var action: (() -> Void)
    var body: some View {
        PetProfileBody(
            profile: self.profile,
            sizeType: self.sizeType,
            funcType:self.funcType,
            isSelected:self.isSelected,
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
    var userId:String? = nil
    var friendStatus:FriendStatus? = nil
    var distance:Double? = nil
    var isSelected:Bool = false
    var action: (() -> Void)? = nil
    var body: some View {
        HorizontalProfile(
            id: self.profile.id,
            type: .pet,
            sizeType: self.sizeType,
            funcType: self.funcType,
            userId: self.userId,
            friendStatus: self.friendStatus,
            image: self.image,
            imagePath: self.imagePath,
            lv: self.lv,
            name: self.name,
            gender: self.gender,
            age: self.age,
            breed: self.distance == nil ? self.breed : nil, //거리와 품종 둘중하나만 표기
            distance:self.distance,
            isSelected: self.isSelected,
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
        .onReceive(self.profile.$isNeutralized){value in
            self.isNeutralized = value
        }
        .onReceive(self.profile.$lv){value in
            self.lv = value
        }
    }
    @State var name:String? = nil
    @State var gender:Gender? = nil
    @State var age:String? = nil
    @State var breed:String? = nil
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil
    @State var isNeutralized:Bool? = nil
    @State var lv:Int? = nil
}
