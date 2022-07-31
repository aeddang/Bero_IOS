//
//  Profile.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/07/31.
//

import Foundation
import SwiftUI

struct ProfileImage:PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var id:String
    var image:UIImage? = nil
    var imagePath:String? = nil
    var size:CGFloat = Dimen.profile.medium
    var emptyImagePath:String = Asset.image.profile_user_default
    var action: (() -> Void)? = nil
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            ZStack{
                if let img = self.image {
                    Image(uiImage: img)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                } else if let path = self.imagePath {
                    ImageView(url: path,
                        contentMode: .fill,
                              noImg: Asset.image.profile_user_default)
                        .modifier(MatchParent())
                } else {
                    Image( uiImage: UIImage(named: self.emptyImagePath)! )
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                }
            }
            .frame(width: self.size, height: self.size)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            
            if let action = self.action{
                ImageButton(
                    defaultImage: Asset.icon.edit,
                    size: CGSize(width: Dimen.icon.thin, height: Dimen.icon.thin),
                    defaultColor: Color.app.grey500
                ){ _ in
                    action()
                }
            }
        }
    }
}

struct ProfileInfoDescription:PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    var id:String
    var age:String? = nil
    var species:String? = nil
    var gender:Gender? = nil
    var useCircle:Bool = true
    var color:Color = Color.app.grey500
    var action: (() -> Void)? = nil
    var body: some View {
        HStack(spacing:useCircle ? Dimen.margin.tiny : 0){
            if let gender = self.gender {
                Text(gender.getSimpleTitle())
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,
                        color: self.color
                    ))
            }
            if let age = self.age {
                if useCircle {
                    Circle()
                        .fill(Color.brand.primary)
                        .frame(width: Dimen.circle.thin, height: Dimen.circle.thin)
                } else {
                    Text(", ")
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,
                            color: self.color
                        ))
                }
                Text(age)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,
                        color: self.color
                    ))
            }
            
            if let species = self.species {
                if useCircle {
                    Circle()
                        .fill(Color.brand.primary)
                        .frame(width: Dimen.circle.thin, height: Dimen.circle.thin)
                } else {
                    Text(", ")
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,
                            color: self.color
                        ))
                }
                    
                Text(species)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,
                        color: self.color
                    ))
            }
            if let action = self.action{
                ImageButton(
                    defaultImage: Asset.icon.edit,
                    size: CGSize(width: Dimen.icon.thin, height: Dimen.icon.thin),
                    defaultColor: self.color
                ){ _ in
                    action()
                }
            }
        }
        .frame(height:Dimen.icon.thin)
    }
}
