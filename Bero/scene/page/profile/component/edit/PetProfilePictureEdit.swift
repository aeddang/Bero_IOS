//
//  ProfilePictureEdit.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/27.
//

import Foundation
import SwiftUI
struct PetProfilePictureEdit: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:PetProfile
 
    @State var image:UIImage? = nil
    @State var imagePath:String? = nil
    var body: some View {
        ZStack(alignment: .bottom){
            ProfileImage(
                id : "",
                image: self.image,
                imagePath: self.imagePath,
                isSelected: true,
                size: Dimen.profile.heavy,
                emptyImagePath: Asset.image.profile_dog_default,
                onEdit: {
                    self.onPick()
                },
                onDelete: {
                    if self.imagePath == nil && self.image == nil {
                        self.onPick()
                    } else {
                        self.onEdit(img: nil)
                    }
                }
            )
        }
        .modifier(MatchHorizontal(height: Dimen.profile.heavy))
        .onReceive(self.profile.$image){ img in
            self.image = img
        }
        .onReceive(self.profile.$imagePath){value in
            self.imagePath = value
        }
    }
    private func onPick(){
        self.appSceneObserver.select = .imgPicker(self.tag){ pick in
            guard let pick = pick else {return}
            self.onEdit(img: pick)
        }
    }
    
    private func onEdit(img:UIImage?){
        self.dataProvider.requestData(q: .init(
            id: self.tag,
            type: .updatePetImage(petId: self.profile.petId, img))
        )
    }
   
}


