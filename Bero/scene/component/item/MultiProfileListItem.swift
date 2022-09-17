//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct MultiProfileListItem: PageComponent{
    var petProfile:PetProfile
    var userProfile:UserProfile
    var body: some View {
        HStack(spacing:Dimen.margin.light){
            VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                HorizontalProfile(
                    type: .pet,
                    imagePath: petProfile.imagePath,
                    name: petProfile.name,
                    gender: petProfile.gender,
                    age: petProfile.birth?.toAge(),
                    useBg: false
                ){ _ in
                    
                }
                if let breed = petProfile.breed, let breedValue = SystemEnvironment.breedCode[breed] {
                    Text(breedValue)
                        .modifier(SemiBoldTextStyle(
                            size: Font.size.thin,
                            color: Color.app.grey400
                        ))
                }
            }
            Spacer().modifier(
                LineVertical(width: Dimen.line.light,color: Color.app.grey100)
            )
            .padding(.vertical, Dimen.margin.tiny)
            VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                HorizontalProfile(
                    type: .user,
                    imagePath: userProfile.imagePath,
                    name: userProfile.nickName,
                    gender: userProfile.gender,
                    age: userProfile.birth?.toAge(),
                    useBg: false
                ){ _ in
                    
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
        .padding(.horizontal, Dimen.margin.light)
        .modifier(MatchHorizontal(height: 104))
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
                petProfile: PetProfile(),
                userProfile: UserProfile()
            )
           
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
