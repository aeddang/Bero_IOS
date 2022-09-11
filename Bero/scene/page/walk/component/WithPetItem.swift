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
    var profile:PetProfile
    @State var isSelect:Bool = false
    var body: some View {
        Button(action: {
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



