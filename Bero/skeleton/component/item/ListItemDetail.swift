//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import struct Kingfisher.KFImage
struct ListDetailItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var imageLoader: ImageLoader = ImageLoader()
    var id:String = UUID().uuidString
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
    var isShared:Bool? = nil
    var isOriginSize:Bool = false
    var pets:[PetProfile] = []
    var iconAction: (() -> Void)? = nil
    var likeAction: (() -> Void)? = nil
    var shareAction: (() -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.thin){
            ZStack{
                if let path = self.imagePath {
                    KFImage(URL(string: path))
                        .onSuccess({ img in
                            if self.isOriginSize {
                                let ratio:CGFloat = img.image.size.height / img.image.size.width
                                self.imageHeight = self.imgSize.width * ratio
                            }
                            
                        })
                        .resizable()
                        .placeholder {
                            Image(self.emptyImage)
                                .resizable()
                                .scaledToFit()
                        }
                    
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                    /*
                    ImageView(
                        imageLoader : self.imageLoader,
                        url: path,
                              contentMode: .fill,
                              noImg: self.emptyImage)
                        .modifier(MatchParent())
                     */
                } else {
                    Spacer()
                        .modifier(MatchParent())
                }
                
                VStack{
                    HStack{
                        Spacer().modifier(MatchHorizontal(height: 0))
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
                        
                    }
                    Spacer()
                    HStack{
                        Spacer().modifier(MatchHorizontal(height: 0))
                        if self.title != nil || self.subTitle != nil {
                            VStack(alignment: .trailing, spacing:0){
                                Spacer().modifier(MatchHorizontal(height: 0))
                                if let text = self.title {
                                    Text(text)
                                        .modifier(SemiBoldTextStyle(
                                            size: Font.size.medium,
                                            color: Color.app.white
                                        ))
                                }
                                if let text = self.subTitle {
                                    Text(text)
                                        .modifier(RegularTextStyle(
                                            size: Font.size.thin,
                                            color: Color.app.white
                                        ))
                                        .padding(.top, Dimen.margin.microExtra)
                                }
                            }
                        }
                        
                    }
                }
                .padding(.all, Dimen.margin.regular)
            }
            .background(Color.app.grey100)
            .frame(width: self.imgSize.width, height: self.imageHeight ?? self.imgSize.height)
            .clipped()
            HStack(spacing:0){
                if let likeAction = self.likeAction {
                    LikeButton(
                        isLike: self.isLike,
                        sizeType: self.likeSize ,
                        likeCount: self.likeCount,
                        action: likeAction
                    )
                }
                Spacer()
                HStack(spacing:Dimen.margin.micro){
                    ForEach(self.pets) { profile in
                        Button(action: {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.dog)
                                    .addParam(key: .id, value: profile.petId)
                            )
                        }) {
                            ProfileImage(
                                image:profile.image,
                                imagePath: profile.imagePath,
                                size: Dimen.profile.thin,
                                emptyImagePath: Asset.image.profile_dog_default
                            )
                        }
                    }
                }
                .fixedSize()
                
                if let isShared = self.isShared {
                    SortButton(
                        type: .stroke,
                        sizeType: .small,
                        icon: Asset.icon.global,
                        text: String.app.share,
                        color: isShared ? Color.brand.primary : Color.app.grey400,
                        isSort: false
                    ){
                        self.shareAction?()
                    }
                    .fixedSize()
                }
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
        }
        .frame(width: self.imgSize.width)
        .onReceive(self.imageLoader.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .complete(let img) :
                let ratio:CGFloat = img.size.height / img.size.width
                self.imageHeight = self.imgSize.width * ratio
            default : break
            }
            
        }
    }
    @State var imageHeight:CGFloat? = nil
}



#if DEBUG
struct ListDetailItem_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            ListDetailItem(
                id: "",
                imgSize: CGSize(width: 320, height: 240),
                title: "title",
                subTitle: "subTitle",
                icon: Asset.icon.paw,
                iconText: "Walk",
                likeCount:0,
                isLike: true,
                isShared: false,
                pets: [
                    PetProfile(data: PetData(), isMyPet: false, index: 0),
                    PetProfile(data: PetData(), isMyPet: false, index: 1),
                    PetProfile(data: PetData(), isMyPet: false, index: 2)
                ]
                
            ){
                
            }
        }
        .padding(.all, 10)
        .background(Color.app.white)
    }
}
#endif
