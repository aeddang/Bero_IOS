//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct VerticalProfile: PageComponent{
    enum ProfileType{
        case pet, user
        var emptyImage:String{
            switch self {
            case .pet : return Asset.image.profile_dog_default
            case .user : return Asset.image.profile_user_default
            }
        }
    }
    enum ProfileSizeType{
        case small, medium
        var imageSize:CGFloat{
            switch self {
            case .small : return Dimen.profile.light
            case .medium : return Dimen.profile.medium
            }
        }
    }
    let id:String
    var type:ProfileType = .pet
    var sizeType:ProfileSizeType = .medium
    var image:UIImage? = nil
    var imagePath:String? = nil
    var lv:Int? = nil
    var name:String? = nil
    var gender:Gender? = nil
    var age:String? = nil
    var breed:String? = nil
    var info:String? = nil
    var description:String? = nil
  
    var editImage: (() -> Void)? = nil
    var editProfile: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            ZStack(alignment: .bottom){
                ProfileImage(
                    id : self.id,
                    image: self.image,
                    imagePath: self.imagePath,
                    size: self.sizeType.imageSize,
                    emptyImagePath: self.type.emptyImage,
                    onEdit: self.editImage
                )
                if let lv = self.lv {
                    CircleButton(
                        type: .text("Lv." + lv.description),
                        isSelected: true,
                        strokeWidth: Dimen.stroke.regular,
                        activeColor: Color.brand.primary
                    ){ _ in
                        
                    }
                    .padding(.leading, self.sizeType.imageSize - Dimen.margin.light)
                }
            }
            .modifier(MatchHorizontal(height: self.sizeType.imageSize))
            VStack(spacing:0){
                if let name = self.name {
                    Text(name)
                        .modifier(SemiBoldTextStyle(
                            size: Font.size.bold,
                            color: Color.app.black
                        ))
                }
                ProfileInfoDescription(
                    id: self.id,
                    age: self.age,
                    breed: self.breed,
                    gender: self.gender,
                    action: self.editProfile
                )
            }
            if let info = self.info{
                Text(info)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,color: Color.app.orange))
                    .padding(.vertical, Dimen.margin.micro)
                    .padding(.horizontal, Dimen.margin.thin)
                    .background(Color.app.orange.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
            }
            
            if let description = self.description{
                ZStack{
                    Text(description)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,color: Color.app.grey400))
                        .padding(.horizontal, Dimen.margin.medium)
                        .modifier(MatchParent())
                }
                .modifier(MatchHorizontal(height: 56))
                .background(Color.app.whiteDeepLight)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
                .modifier(ShadowLight())
            }
        }
    }
}



#if DEBUG
struct VerticalProfile_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(spacing:20){
            VerticalProfile(
                id: "",
                type: .pet,
                sizeType: .medium,
                image: nil,
                imagePath: nil,
                lv:99,
                name: "name",
                gender: .female,
                age: "20",
                breed: "dog",
                info: "info",
                description: "description"
            )
            VerticalProfile(
                id: "",
                type: .user,
                sizeType: .small,
                image: nil,
                imagePath: nil,
                name: "name",
                gender: .female,
                age: "20",
                breed: nil,
                info: "info",
                description: "description"
            )
        }
        .padding(.all, 10)
        .frame(width: 320)
        .background(Color.app.white)
    }
}
#endif
