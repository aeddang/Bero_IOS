//
//  ProfilePictureEdit.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/27.
//

import Foundation
import SwiftUI
struct UserProfilePictureEdit: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:UserProfile
    var user:SnsUser? = nil
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
                emptyImagePath: Asset.image.profile_user_default,
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
            DispatchQueue.global(qos:.background).async {
                let scale:CGFloat = 1 //UIScreen.main.scale
                let sizeList = CGSize(
                    width: AlbumApi.thumbSize * scale,
                    height: AlbumApi.thumbSize * scale)
                let thumbImage = pick.normalized().crop(to: sizeList).resize(to: sizeList)
                DispatchQueue.main.async {
                    self.pagePresenter.isLoading = false
                    self.onEdit(img: thumbImage)
                }
            }
           
        }
    }
    
    private func onEdit(img:UIImage?){
        guard let user = self.user else {return}
        self.dataProvider.requestData(q: .init(
            id: self.tag,
            type: .updateUserImage(user, img))
        )
    }
   
}


