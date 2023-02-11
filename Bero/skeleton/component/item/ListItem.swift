//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct ListItem: PageComponent{
    let id:String
    var imagePath:String? = nil
    var emptyImage:String = Asset.noImg1_1
    var imgSize:CGSize = CGSize(width: 100, height: 100)
    var title:String? = nil
    var subTitle:String? = nil
    var icon:String? = nil
    var iconText:String? = nil
    var iconColor:Color = Color.app.black
    var iconSize:SortButton.SizeType = .big
    var likeCount:Double? = nil
    var isLike:Bool = false
    var likeSize:SortButton.SizeType = .big
    var pets:[PetProfile] = []
    var iconAction: (() -> Void)? = nil
    var action: (() -> Void)? = nil
    var move:(() -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.thin){
            ZStack{
                Button(action: {
                    self.move?()
                }) {
                    if let path = self.imagePath {
                        ImageView(url: path,
                                  contentMode: .fill,
                                  noImg: self.emptyImage)
                            .modifier(MatchParent())
                    } else {
                        Image(Asset.noImg16_9)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .modifier(MatchParent())
                    }
                }
                
                VStack{
                    HStack{
                        if let icon = self.icon {
                            SortButton(
                                type: .stroke,
                                sizeType: self.iconSize,
                                icon: icon,
                                text: self.iconText ?? "",
                                color: self.iconColor,
                                isSort: false
                            ){
                                self.iconAction?()
                            }
                            .fixedSize()
                        }
                        Spacer().modifier(MatchHorizontal(height: 0))
                    }
                    Spacer()
                    HStack{
                        Spacer().modifier(MatchHorizontal(height: 0))
                        if let likeCount = self.likeCount {
                            SortButton(
                                type: .stroke,
                                sizeType: self.likeSize,
                                icon: self.isLike ? Asset.icon.favorite_on : Asset.icon.favorite_off,
                                text: likeCount.toThousandUnit(),
                                color: self.isLike ? Color.brand.primary : Color.app.grey400,
                                isSort: false
                            ){
                                self.action?()
                            }
                            .fixedSize()
                        }
                    }
                }
                .padding(.all, Dimen.margin.tiny)
            }
            
            .background(Color.app.grey100)
            .frame(width: self.imgSize.width, height: self.imgSize.height)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
            HStack(spacing:0){
                if self.title != nil || self.subTitle != nil {
                    VStack(alignment: .leading, spacing:0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        if let text = self.title {
                            Text(text)
                                .modifier(SemiBoldTextStyle(
                                    size: Font.size.light,
                                    color: Color.app.black
                                ))
                        }
                        if let text = self.subTitle {
                            Text(text)
                                .modifier(RegularTextStyle(
                                    size: Font.size.thin,
                                    color: Color.app.grey300
                                ))
                                .padding(.top, Dimen.margin.microExtra)
                        }
                    }
                }
                if !self.pets.isEmpty, let pets = self.pets.reversed() {
                    ZStack(alignment: .trailing){
                        ForEach(pets) { profile in
                            ProfileImage(
                                image:profile.image,
                                imagePath: profile.imagePath,
                                size: Dimen.profile.thin,
                                emptyImagePath: Asset.image.profile_dog_default
                            )
                            .padding(.trailing, Dimen.margin.thin * CGFloat(profile.index))
                        }
                    }
                }
            }
        }
        .frame(width: self.imgSize.width)
    }
}



#if DEBUG
struct ListItem_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            ListItem(
                id: "",
                imgSize: CGSize(width: 240, height: 160),
                title: "title",
                subTitle: "subTitle",
                icon: Asset.icon.paw,
                iconText: "Walk",
                likeCount:0,
                isLike: true,
                pets: [
                    PetProfile(data: PetData(), isMyPet: false, index: 0),
                    PetProfile(data: PetData(), isMyPet: false, index: 1),
                    PetProfile(data: PetData(), isMyPet: false, index: 2),
                    PetProfile(data: PetData(), isMyPet: false, index: 3)
                ]
            ){
                
            }
        }
        .padding(.all, 10)
        .background(Color.app.white)
    }
}
#endif
