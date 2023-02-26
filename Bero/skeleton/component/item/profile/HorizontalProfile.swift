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
        case pet, user, place(icon:String = Asset.icon.goal), multi(imgPath:String?)
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
        
        var radius:CGFloat {
            switch self {
            default : return Dimen.radius.light
            }
        }
        var padding:CGFloat {
            switch self {
            default : return Dimen.margin.regularExtra
            }
        }
    }
    enum SizeType{
        case small, big, tiny
        var imageSize:CGFloat{
            switch self {
            case .tiny : return Dimen.profile.lightExtra
            case .small : return Dimen.profile.regular
            case .big : return Dimen.profile.heavyExtra
            }
        }
        var lvType:LvButton.ButtonType{
            switch self {
            case .small, .tiny : return .tiny
            case .big : return .small
            }
        }
        var titleSpacing:CGFloat{
            switch self {
            case .small, .tiny : return Dimen.margin.micro
            case .big : return Dimen.margin.light
            }
        }
        var nameSize:CGFloat{
            switch self {
            case .small, .tiny : return Font.size.light
            case .big : return Font.size.medium
            }
        }
    }
    enum FuncType{
        case addFriend, button(String), more, moreFunc, delete, send, check(Bool),
             view(String, color:Color = Color.brand.primary), block(Bool)
        
        var strokeColor:Color? {
            switch self {
            case .check(let isCheck) : return isCheck ? Color.brand.primary : nil
            default : return nil
            }
        }
    }
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var id:String = UUID().uuidString
    var type:ProfileType = .pet
    var sizeType:SizeType = .small
    var funcType:FuncType? = nil
    var userId:String? = nil
    var friendStatus:FriendStatus? = nil
    var color:Color = Color.brand.primary
    var image:UIImage? = nil
    var imagePath:String? = nil
    var lv:Int? = nil
    var name:String? = nil
    var date:String? = nil
    var gender:Gender? = nil
    var isNeutralized:Bool? = nil
    var age:String? = nil
    var breed:String? = nil
    var description:String? = nil
    var distance:Double? = nil
    var withImagePath:String? = nil
    var isSelected:Bool = false
    var isEmpty:Bool = false
    var useBg:Bool = true
    var bgColor:Color = Color.app.white
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
            case .multi(let imgPath) :
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
                ZStack(alignment: .bottomTrailing){
                    ProfileImage(
                        id : self.id,
                        image: self.image,
                        imagePath: self.imagePath,
                        size: self.sizeType.imageSize,
                        emptyImagePath: self.type.emptyImage)
                    if let value = self.lv, let lv = Lv.getLv(value) {
                        LvButton(
                            lv: lv,
                            type: self.sizeType.lvType,
                            text: value.description
                        ){_ in
                            self.appSceneObserver.event = .toast(lv.title)
                        }
                    }
                }
                .onTapGesture(){
                    self.action?(nil)
                }
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
                    if self.name != nil || self.date != nil {
                        HStack(spacing: Dimen.margin.thin){
                            if let name = self.name {
                                Text(name)
                                    .modifier(SemiBoldTextStyle(
                                        size: self.sizeType.nameSize,
                                        color: self.isSelected ? Color.app.white : Color.app.black
                                    ))
                                    .multilineTextAlignment(.leading)
                            }
                            if let date = self.date {
                                Text(date)
                                    .modifier(RegularTextStyle(
                                        size: Font.size.tiny,
                                        color: Color.app.grey300
                                    ))
                                    .fixedSize()
                            }
                        }
                        .padding(.bottom, self.sizeType.titleSpacing)
                    }
                    VStack(alignment: .leading, spacing:Dimen.margin.micro){
                        if self.gender != nil || self.age != nil {
                            ProfileInfoDescription(
                                id: self.id,
                                age: self.age,
                                gender: self.gender,
                                isNeutralized: self.isNeutralized,
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
                                .lineLimit(1)
                        }
                        HStack(spacing: Dimen.margin.tiny){
                            if let description = self.description {
                                Text(description)
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color: self.isSelected ? Color.app.white : Color.app.grey500
                                    ))
                                    .lineLimit(2)
                            }
                            
                            if let distance = self.distance {
                                Text(WalkManager.viewDistance(distance))
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color: self.isSelected ? Color.app.white : self.color
                                    ))
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            if let status = self.friendStatus, let userId = self.userId {
                HStack( spacing: Dimen.margin.micro){
                    ForEach(status.buttons, id:\.rawValue){ btn in
                        FriendButton(
                            type:.icon,
                            userId:userId,
                            funcType: btn
                        )
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
                case .moreFunc :
                    ImageButton(
                        defaultImage: Asset.icon.more_vert,
                        defaultColor: self.isSelected ? Color.app.white : Color.app.grey400
                    ){ _ in
                        self.action?(funcType)
                    }
                case .block(let isBlock) :
                    ImageButton(
                        defaultImage: Asset.icon.block,
                        defaultColor: self.isSelected ? Color.app.white : Color.app.grey400
                    ){ _ in
                        self.action?(funcType)
                    }
                    .opacity(isBlock ? 1 : 0.5)
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
                case .send :
                    CircleButton(
                        type: .icon(Asset.icon.chat),
                        isSelected: true,
                        activeColor: self.color
                    ){ _ in
                        self.action?(funcType)
                    }
                case .check(let isCheck) :
                    CircleButton(
                        type: .icon(Asset.icon.check),
                        isSelected: true,
                        activeColor: isCheck ? self.color : Color.app.grey100
                    ){ _ in
                        self.action?(funcType)
                    }
                case .view(let str, let color) :
                    Text(str)
                        .modifier(MediumTextStyle(
                            size: Font.size.tiny,
                            color: Color.app.white
                        ))
                        .padding(.all, Dimen.margin.micro)
                        .background(color)
                        .clipShape(Circle())
                        .onTapGesture{
                            self.action?(funcType)
                        }
                }
            }
            if let path = self.withImagePath {
                ImageView(
                    url: path,
                    contentMode: .fill,
                    noImg: Asset.noImg1_1)
                .frame(width: Dimen.button.medium, height: Dimen.button.medium)
                .background(Color.app.grey50)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.tiny))
                .onTapGesture{
                    self.action?(.view(path, color: .black))
                }
            }
        }
        .padding(.all, self.useBg ? self.type.padding : 0)
        .background(self.useBg
                    ? self.isSelected && !self.isEmpty ? self.color : self.bgColor
                    : Color.transparent.clearUi
        )
        .clipShape(RoundedRectangle(cornerRadius: self.useBg ? self.type.radius : 0))
        .overlay(
            RoundedRectangle(cornerRadius: self.type.radius)
                .strokeBorder(
                    self.funcType?.strokeColor ?? Color.app.grey100,
                    lineWidth: self.useBg ? Dimen.stroke.light : 0
                )
        )
        .modifier(ShadowLight( opacity: self.useBg ? 0.05 : 0 ))
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
                withImagePath: "",
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
                description: "August 23, 2023"
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
            
            HorizontalProfile(
                id: "",
                type: .pet,
                funcType: .check(true),
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
                type: .user,
                sizeType: .big,
                funcType: .addFriend,
                image: nil,
                imagePath: nil,
                name: "name",
                gender: .female,
                age: "20",
                breed: "dog",
                isSelected: false,
                useBg: false
                
            )
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
