//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



class UserListItemData:InfinityData{
    private(set) var albumData:AlbumListItemData? = nil
    private(set) var userProfile:UserProfile? = nil
    private(set) var petProfile:PetProfile? = nil
    private(set) var date:String? = nil
    
    
    func setData(_ data:PictureData, idx:Int) -> UserListItemData {
        self.index = idx
        self.albumData = AlbumListItemData().setData(data, idx: 0)
        if let user = data.user {
            self.userProfile = UserProfile().setData(data: user)
        }
        if let pet = data.pets?.first(where: {$0.isRepresentative == true}) {
            self.petProfile = PetProfile(data: pet, userId: self.userProfile?.userId)
        }
        self.date = data.createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")?.toDateFormatter(dateFormat: "EEEE, MMMM d, yyyy")
        return self
    }
    
    var postId:String? {
        get {
            return self.albumData?.pictureId.description
        }
    }
}

struct UserListItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var data:UserListItemData
    let imgSize:CGSize
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            if let user = self.data.userProfile {
                if let pet = self.data.petProfile {
                    UserProfileItem(
                        data: user,
                        type: .pet,
                        postId: self.data.postId,
                        title: pet.name,
                        lv: pet.lv,
                        imagePath: pet.imagePath,
                        date: self.data.date,
                        action:self.moveUser
                    )
                    .padding(.vertical, Dimen.margin.regularExtra)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                } else {
                    UserProfileItem(
                        data: user,
                        type: .user,
                        postId: self.data.postId,
                        title: user.nickName,
                        lv: user.lv,
                        imagePath: user.imagePath,
                        date: self.data.date,
                        action:self.moveUser
                    )
                    .padding(.vertical, Dimen.margin.regularExtra)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                }
            }
            if let albumData = self.data.albumData{
                AlbumListDetailItem(data: albumData, imgSize: self.imgSize, isEdit: .constant(false))
            }
        }
        
        
    }
    private func moveUser(){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.user)
                .addParam(key: .id, value:self.data.userProfile?.userId)
        )
    }
}



