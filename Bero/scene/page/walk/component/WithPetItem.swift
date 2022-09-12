//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct WithPetItem: PageComponent{
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var profile:PetProfile
    @State var isSelect:Bool = false
    var body: some View {
        Button(action: {
            if self.isSelect && dataProvider.user.pets.filter({$0.isWith}).count < 2 {
                self.appSceneObserver.event = .toast(String.alert.walkDisableEmptyWithPet )
                return
            }
            self.isSelect.toggle()
            profile.isWith = self.isSelect
            
        }) {
            ProfileImage(
                image:profile.image,
                imagePath: profile.imagePath,
                isSelected: self.isSelect,
                size: Dimen.profile.thin,
                emptyImagePath: Asset.image.profile_dog_default
            )
        }
        .onAppear(){
            self.isSelect = self.profile.isWith
        }
    }
}



