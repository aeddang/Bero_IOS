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
        case pet, user, place(icon:String = Asset.icon.goal), multi(imgPath:String?, useDescription:Bool = false)
        var emptyImage:String{
            switch self {
            case .pet : return Asset.image.profile_dog_default
            case .user : return Asset.image.profile_user_default
            default : return ""
            }
        }
        var emptyTitle:String{
            switch self {
            case .pet : return String.pageTitle.addDog
            default : return ""
            }
        }
        
        
        var useDescription:Bool{
            switch self {
            case .multi(_ , let useDescription) : return useDescription
            case .place : return false
            default : return true
            }
        }
        
        var radius:CGFloat {
            switch self {
            case .multi : return 0
            default : return Dimen.radius.light
            }
            
        }
    }
    enum SizeType{
        case small, big
        var imageSize:CGFloat{
            switch self {
            case .small : return Dimen.profile.regular
            case .big : return Dimen.profile.heavyExtra
            }
        }
        var titleSpacing:CGFloat{
            switch self {
            case .small : return Dimen.margin.micro
            case .big : return Dimen.margin.light
            }
        }
        var nameSize:CGFloat{
            switch self {
            case .small : return Font.size.light
            case .big : return Font.size.medium
            }
        }
    }
    enum FuncType{
        case addFriend, button(String), more, delete
    }
    
    var id:String = UUID().uuidString
    var type:ProfileType = .pet
    var sizeType:SizeType = .small
    var funcType:FuncType? = nil
    var color:Color = Color.brand.primary
    var image:UIImage? = nil
    var imagePath:String? = nil
    var name:String? = nil
    var date:String? = nil
    var adress:String? = nil
    var gender:Gender? = nil
    var age:String? = nil
    var breed:String? = nil
    var description:String? = nil
    var distance:Double? = nil
    var isSelected:Bool = false
    var isEmpty:Bool = false
    
    var action: ((FuncType?) -> Void)? = nil
    
    var body: some View {
        HStack(spacing:Dimen.margin.regularExtra){
            switch self.type {
            case .place(let icon) :
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.isSelected ? Color.app.white : self.color)
                    .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    .frame(width: Dimen.button.medium, height: Dimen.button.medium)
                    .background(Color.app.orangeSub)
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
            case .multi(let imgPath, _) :
                MultiProfile(
                    type: .user,
                    sizeType: .small,
                    circleButtontype: .image(imgPath ?? "", size: Dimen.icon.light),
                    image: self.image,
                    imagePath: self.imagePath,
                    imageSize: Dimen.profile.thin
                ){
                    self.action?(nil)
                }
                .frame(width: Dimen.profile.thin)
            default :
                ProfileImage(
                    id : self.id,
                    image: self.image,
                    imagePath: self.imagePath,
                    size: self.sizeType.imageSize,
                    emptyImagePath: self.type.emptyImage)
            }
            
        
            VStack(alignment: .leading, spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                if self.isEmpty {
                    Text(self.type.emptyTitle)
                        .modifier(SemiBoldTextStyle(
                            size: Font.size.medium,
                            color: Color.app.grey300
                        ))
                        .padding(.bottom, self.sizeType.titleSpacing)
                    if let description = self.description {
                        Text(description)
                            .modifier(RegularTextStyle(
                                size: Font.size.thin,
                                color: Color.app.grey300
                            ))
                    }
                } else {
                    if let name = self.name {
                        Text(name)
                            .modifier(SemiBoldTextStyle(
                                size: self.sizeType.nameSize,
                                color: self.isSelected ? Color.app.white : Color.app.black
                            ))
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, self.sizeType.titleSpacing)
                        
                    }
                    VStack(alignment: .leading, spacing:Dimen.margin.micro){
                        if self.type.useDescription {
                            ProfileInfoDescription(
                                id: self.id,
                                age: self.age,
                                gender: self.gender,
                                useCircle: false,
                                color: self.isSelected ? Color.app.white : Color.app.grey500
                            )
                        }
                        
                        
                        if let breed = self.breed, let breedValue = SystemEnvironment.breedCode[breed] {
                            Text( breedValue)
                                .modifier(RegularTextStyle(
                                    size: Font.size.thin,
                                    color: self.isSelected ? Color.app.white : self.color
                                ))
                                .multilineTextAlignment(.leading)
                        }
                        HStack(spacing: Dimen.margin.tiny){
                            if let description = self.description {
                                Text(description)
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color: self.isSelected ? Color.app.white : Color.app.grey500
                                    ))
                                    .multilineTextAlignment(.leading)
                            }
                            
                            if let distance = self.distance {
                                Text(WalkManager.viewDistance(distance))
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color: self.isSelected ? Color.app.white : self.color
                                    ))
                                    .multilineTextAlignment(.leading)
                            }
                            if let date = self.date {
                                Text(date)
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color: self.isSelected ? Color.app.white : Color.app.grey500
                                    ))
                                    .multilineTextAlignment(.leading)
                            }
                            if let adress = self.adress {
                                Text(adress)
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color: self.isSelected ? Color.app.white : Color.app.grey500
                                    ))
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                }
            }
            if self.isEmpty {
                ImageButton(
                    defaultImage: Asset.icon.add,
                    defaultColor: self.isSelected ? Color.app.white : self.color
                ){ _ in
                    action?(nil)
                }
            } else if let funcType = self.funcType {
                switch funcType {
                case .delete :
                    ImageButton(
                        defaultImage: Asset.icon.delete,
                        defaultColor: self.isSelected ? Color.app.white : Color.app.grey400
                    ){ _ in
                        self.action?(funcType)
                    }
                case .more :
                    ImageButton(
                        defaultImage: Asset.icon.direction_right,
                        defaultColor: self.isSelected ? Color.app.white : Color.app.grey400
                    ){ _ in
                        self.action?(funcType)
                    }
                case .button(let text) :
                    SortButton(
                        type: .fill,
                        sizeType: .small,
                        text: text,
                        color: self.isSelected ? Color.app.white : self.color,
                        isSort: false
                    ){
                        self.action?(funcType)
                    }
                case .addFriend :
                    CircleButton(
                        type: .icon(Asset.icon.add_friend),
                        isSelected: true,
                        activeColor: self.color
                    ){ _ in
                        self.action?(funcType)
                    }
                }
            }
        }
        .padding(.all, Dimen.margin.regularExtra)
        .background(self.isSelected && !self.isEmpty ? self.color : Color.app.white )
        .clipShape(RoundedRectangle(cornerRadius: self.type.radius))
        .overlay(
            RoundedRectangle(cornerRadius: self.type.radius)
                .strokeBorder(
                    Color.app.grey100,
                    lineWidth: self.type.radius == 0 ? 0 : Dimen.stroke.light
                )
        )
        .modifier(ShadowLight( opacity: self.type.radius == 0 ? 0 : 0.05 ))
    }
}


#if DEBUG
struct HorizontalProfile_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            HorizontalProfile(
                id: "",
                type: .pet,
                funcType: .button("button"),
                color: Color.brand.primary,
                image: nil,
                imagePath: nil,
                name: "name",
                gender: .female,
                age: "20",
                breed: "dog"
            ){ _ in
                
            }
            HorizontalProfile(
                id: "",
                type: .pet,
                color: Color.brand.primary,
                image: nil,
                imagePath: nil,
                name: "name",
                gender: .female,
                age: "20",
                breed: "dog",
                isSelected: true
            ){ _ in
                
            }
            HorizontalProfile(
                id: "",
                type: .pet,
                sizeType: .small,
                image: nil,
                imagePath: nil,
                description: String.pageText.addDogEmpty,
                isEmpty: true
            ){ _ in
                
            }
            HorizontalProfile(
                id: "",
                type: .place(),
                sizeType: .small,
                color: Color.app.red,
                name: "name",
                date: "August 23, 2023"
            ){ _ in
                
            }
            HorizontalProfile(
                id: "",
                type: .user,
                sizeType: .big,
                funcType: .addFriend,
                image: nil,
                imagePath: nil,
                name: "name",
                gender: .female,
                age: "20",
                breed: "dog",
                isSelected: false
            )
            
            HorizontalProfile(
                id: "",
                type: .multi(imgPath: ""),
                sizeType: .small,
                funcType: .addFriend,
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
