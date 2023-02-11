import Foundation
import SwiftUI

struct PetProfileTopInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var profile:PetProfile
    var distance:Double? = nil
    var isHorizontal:Bool = false
    var isSimple:Bool = false
    var action: (() -> Void)? = nil
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            if !self.isHorizontal {
                VerticalProfile(
                    id: self.profile.id,
                    type: .pet,
                    alignment: .center,//self.isSimple ? .leading : .center,
                    sizeType: .medium,
                    isSelected: true,
                    image: self.image,
                    imagePath: self.imagePath,
                    lv: self.profile.lv,
                    name: self.name,
                    gender: self.gender,
                    isNeutralized: self.isNeutralized,
                    age: self.age,
                    breed: self.breed,
                    description: self.isSimple ? nil : self.description,
                    editProfile: self.profile.isMypet ? self.action : nil
                )
            } else {
                HorizontalProfile(
                    id: self.profile.id,
                    type: .pet,
                    sizeType: .big,
                    funcType: nil,
                    image: self.image,
                    imagePath: self.imagePath,
                    lv: self.profile.lv,
                    name: self.name,
                    gender: self.gender,
                    isNeutralized: self.isNeutralized,
                    age: self.age,
                    breed: self.distance == nil ? self.breed : nil,
                    distance: self.distance,
                    isSelected: false,
                    useBg: false,
                    action: { _ in
                        self.action?()
                    }
                )
                .onTapGesture {
                    self.action?()
                }
                if !self.isSimple, let description = self.description{
                    ZStack{
                        Spacer().modifier(MatchHorizontal(height: 0))
                        Text(description)
                            .modifier(VerticalProfile.descriptionStyle)
                            .padding(.all, VerticalProfile.descriptionPadding)
                            .multilineTextAlignment(.center)
                    }
                    .background(Color.app.whiteDeepLight)
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
                }
            }
        }
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
        .onReceive(self.profile.$isNeutralized){value in
            self.isNeutralized = value
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
    @State var isNeutralized:Bool? = nil
}


