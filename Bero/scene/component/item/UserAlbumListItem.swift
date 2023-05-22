//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



class UserAlbumListItemData:InfinityData{
    private(set) var albumData:AlbumListItemData? = nil
    private(set) var userProfile:UserProfile? = nil
    private(set) var petProfile:PetProfile? = nil
    private(set) var date:String? = nil
    private(set) var lv:Int? = nil
    
    func setData(_ data:PictureData, idx:Int = -1) -> UserAlbumListItemData {
        self.index = idx
        self.albumData = AlbumListItemData().setData(data, idx: 0)
        if let user = data.user {
            self.userProfile = UserProfile().setData(data: user)
            self.lv = user.level
        }
        if let pet = data.pets?.first(where: {$0.isRepresentative == true}) {
            self.petProfile = PetProfile(data: pet, userId: self.userProfile?.userId)
        }
        self.date = data.createdAt?.toDate()?.toDateFormatter(dateFormat: "MMMM d, yyyy")
        return self
    }
    
    var postId:String? {
        get {
            return self.albumData?.pictureId.description
        }
    }
}

struct UserAlbumListItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var data:UserAlbumListItemData
    let imgSize:CGSize
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            if let user = self.data.userProfile {
                if let pet = self.data.petProfile {
                    UserProfileItem(
                        data: user,
                        type: .pet,
                        reportType : .post,
                        postId: self.data.postId,
                        title: pet.name,
                        lv: self.data.lv,
                        imagePath: pet.imagePath,
                        date: self.data.date,
                        action:self.moveUser
                    )
                    .padding(.vertical, Dimen.margin.regularExtra)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    .zIndex(99)
                } else {
                    UserProfileItem(
                        data: user,
                        type: .user,
                        reportType : .post,
                        postId: self.data.postId,
                        title: user.nickName,
                        lv: self.data.lv,
                        imagePath: user.imagePath,
                        date: self.data.date,
                        action:self.moveUser
                    )
                    .padding(.vertical, Dimen.margin.regularExtra)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    .zIndex(99)
                }
            }
            if let albumData = self.data.albumData{
                AlbumListDetailItem(data: albumData, userProfile: self.data.userProfile, imgSize: self.imgSize, isEdit: .constant(false))
                    .onTapGesture {
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pictureViewer)
                                .addParam(key: .data, value: albumData)
                                //.addParam(key: .userData, value: self.data.userProfile)
                        )
                    }
                    
            }
        }
        
        
    }
    private func moveUser(){
        guard let id = self.data.userProfile?.userId else {return}
        if self.dataProvider.user.isSameUser(userId: id) {
            self.appSceneObserver.event = .toast(String.alert.itsMe)
            
        } else {
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.user).addParam(key: .id, value:id)
            )
        }
        
    }
}



