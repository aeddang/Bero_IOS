//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct HorizontalProfile: PageComponent{
    enum ProfileType{
        case pet, user
        var emptyImage:String{
            switch self {
            case .pet : return Asset.image.profile_dog_default
            case .user : return Asset.image.profile_user_default
            }
        }
    }
    
    let id:String
    var type:ProfileType = .pet
    var color:Color = Color.brand.primary
    var image:UIImage? = nil
    var imagePath:String? = nil
    var name:String? = nil
    var gender:Gender? = nil
    var age:String? = nil
    var breed:String? = nil
    var isSelected:Bool = false
    var action: (() -> Void)? = nil
    var body: some View {
        HStack(spacing:Dimen.margin.regularExtra){
            ProfileImage(
                id : self.id,
                image: self.image,
                imagePath: self.imagePath,
                size: Dimen.profile.regular,
                emptyImagePath: self.type.emptyImage)
            VStack(alignment: .leading, spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                if let name = self.name {
                    Text(name)
                        .modifier(SemiBoldTextStyle(
                            size: Font.size.medium,
                            color: self.isSelected ? Color.app.white : Color.app.black
                        ))
                        .multilineTextAlignment(.leading)
                }
                ProfileInfoDescription(
                    id: self.id,
                    age: self.age,
                    breed: self.breed,
                    gender: self.gender,
                    useCircle: false,
                    color: self.isSelected ? Color.app.white : Color.app.grey500
                )
            }
            if let action = self.action {
                ImageButton(
                    defaultImage: Asset.icon.direction_right,
                    defaultColor: self.isSelected ? Color.app.white : Color.app.grey500
                ){ _ in
                    action()
                }
            }
        }
        .padding(.all, Dimen.margin.regularExtra)
        .background(self.isSelected ? self.color : Color.app.white )
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
    }
}


#if DEBUG
struct HorizontalProfile_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            HorizontalProfile(
                id: "",
                type: .pet,
                color: Color.app.red,
                image: nil,
                imagePath: nil,
                name: "name",
                gender: .female,
                age: "20",
                breed: "dog",
                isSelected: true
            ){
                
            }
            HorizontalProfile(
                id: "",
                type: .user,
                image: nil,
                imagePath: nil,
                name: "name",
                gender: .female,
                age: "20",
                breed: "dog",
                isSelected: false
            )
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
