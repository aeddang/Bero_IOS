//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
class MultiProfileListItemData:InfinityData{
    private(set) var user:UserProfile? = nil
    private(set) var pet:PetProfile? = nil
    func setData(_ data:PlaceVisitor, idx:Int) -> MultiProfileListItemData{
        self.index = idx
        self.contentID = data.user?.userId ?? ""
        if let userData = data.user {
            self.user = UserProfile().setData(data: userData)
        }
        if let petData = data.pet {
            self.pet = PetProfile(data: petData)
        }
        return self
    }
}
struct MultiProfileListItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var data:MultiProfileListItemData = MultiProfileListItemData()
    var body: some View {
        HStack(spacing:Dimen.margin.light){
            if let petProfile = self.data.pet {
                VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                    HorizontalProfile(
                        type: .pet,
                        imagePath: petProfile.imagePath,
                        lv: petProfile.lv,
                        name: petProfile.name,
                        gender: petProfile.gender,
                        age: petProfile.birth?.toAge(),
                        useBg: false
                    ){ _ in
                        
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.dog)
                                .addParam(key: .data, value:petProfile)
                        )
                    }
                    if let breed = petProfile.breed, let breedValue = SystemEnvironment.breedCode[breed] {
                        Text(breedValue)
                            .modifier(SemiBoldTextStyle(
                                size: Font.size.thin,
                                color: Color.app.grey400
                            ))
                    }
                }
            }
            Spacer().modifier(
                LineVertical(width: Dimen.line.light,color: Color.app.grey100)
            )

            if let userProfile = self.data.user {
                VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                    HorizontalProfile(
                        type: .user,
                        imagePath: userProfile.imagePath,
                        lv: userProfile.lv,
                        name: userProfile.nickName,
                        gender: userProfile.gender,
                        age: userProfile.birth?.toAge(),
                        useBg: false
                    ){ _ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.user)
                                .addParam(key: .id, value:userProfile.userId)
                        )
                    }
                    HStack(spacing:Dimen.margin.tinyExtra){
                        Image(Lv.getLv(userProfile.lv).icon)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Lv.getLv(userProfile.lv).color)
                            .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                        Text(Lv.getLv(userProfile.lv).title)
                            .modifier(SemiBoldTextStyle(
                                size: Font.size.thin,
                                color: Color.app.grey400
                            ))
                    }
                }
            }
        }
        .padding(.all, Dimen.margin.light)
        .modifier(MatchHorizontal(height: 124))
        .background(Color.app.white )
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.light)
                .strokeBorder(
                    Color.app.grey100,
                    lineWidth: Dimen.stroke.light
                )
        )
        .modifier(ShadowLight())
    }
}


#if DEBUG
struct MultiProfileListItem_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            MultiProfileListItem(
                data: MultiProfileListItemData()
            )
           
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
