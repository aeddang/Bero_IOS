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
    @EnvironmentObject var appSceneObserver:AppSceneObserver
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
    static let descriptionStyle = RegularTextStyle(size: Font.size.thin,color: Color.app.grey400)
    static let descriptionPadding = Dimen.margin.light
    let id:String
    var type:ProfileType = .pet
    var alignment:HorizontalAlignment = .center
    var sizeType:ProfileSizeType = .medium
    var isSelected:Bool = false
    var image:UIImage? = nil
    var imagePath:String? = nil
    var lv:Int? = nil
    var name:String? = nil
    var gender:Gender? = nil
    var age:String? = nil
    var breed:String? = nil
    var info:String? = nil
    var description:String? = nil
    var editProfile: (() -> Void)? = nil
    var body: some View {
        VStack(alignment: self.alignment, spacing:Dimen.margin.regularExtra){
            ZStack(alignment: self.alignment == .center ? .bottom : .bottomLeading){
                ProfileImage(
                    id : self.id,
                    image: self.image,
                    imagePath: self.imagePath,
                    size: self.sizeType.imageSize,
                    emptyImagePath: self.type.emptyImage,
                    onEdit: self.editProfile
                )
                if let edit = self.editProfile {
                    CircleButton(
                        type: .icon(Asset.icon.edit),
                        isSelected: false,
                        strokeWidth: Dimen.stroke.regular,
                        defaultColor: Color.app.black
                    ){ _ in
                        edit()
                    }
                    .padding(.leading, self.sizeType.imageSize - Dimen.margin.light)
                }else if let value = self.lv, let lv = Lv.getLv(value) {
                    HeartButton(
                        text: value.description,
                        activeColor: lv.color,
                        isSelected: true
                    ){_ in
                        self.appSceneObserver.event = .toast(lv.title)
                    }
                    .padding(.leading, self.sizeType.imageSize - Dimen.margin.light)
                }
                if self.alignment == .center {
                    Spacer().modifier(MatchHorizontal(height: self.sizeType.imageSize))
                } else {
                    Spacer().frame(width:self.sizeType.imageSize, height: self.sizeType.imageSize)
                }
            }
            VStack(alignment: self.alignment, spacing:Dimen.margin.micro){
                if let name = self.name {
                    Text(name)
                        .modifier(SemiBoldTextStyle(
                            size: Font.size.bold,
                            color: Color.app.black
                        ))
                        .multilineTextAlignment(self.alignment == .center ? .center : .leading)
                }
                ProfileInfoDescription(
                    id: self.id,
                    age: self.age,
                    breed: self.breed,
                    gender: self.gender,
                    action: nil
                )
            }
            if let info = self.info{
                Text(info)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,color: Color.app.orange))
                    .padding(.vertical, Dimen.margin.micro)
                    .padding(.horizontal, Dimen.margin.thin)
                    .multilineTextAlignment(self.alignment == .center ? .center : .leading)
                    .background(Color.app.orange.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
                
            }
            
            if let description = self.description{
                ZStack{
                    Spacer().modifier(MatchHorizontal(height: 0))
                    Text(description)
                        .modifier(Self.descriptionStyle)
                        .padding(.all, Self.descriptionPadding)
                        .modifier(MatchParent())
                        .multilineTextAlignment(self.alignment == .center ? .center : .leading)
                }
                .background(Color.app.whiteDeepLight)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
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
                sizeType: .medium,
                image: nil,
                imagePath: nil,
                lv:nil,
                name: "name",
                gender: .female,
                age: "20",
                description: "description",
                editProfile: {
                    
                }
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
