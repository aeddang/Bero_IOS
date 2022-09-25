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
    private(set) var walkData:WalkListItemData? = nil
    private(set) var albumData:AlbumListItemData? = nil
    private(set) var userProfile:UserProfile? = nil
    private(set) var subImagePath:String? = nil
    private(set) var date:String? = nil
   
    func setData(_ data:MissionData, idx:Int) -> UserListItemData {
        self.walkData = WalkListItemData().setData(data, idx: 0)
        if let user = data.user {
            self.userProfile = UserProfile().setData(data: user)
        }
        self.subImagePath = data.pets?.first?.pictureUrl
        self.date = data.createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")?.toDateFormatter(dateFormat: "EEEE, MMMM d, yyyy")
        return self
    }
    
    func setData(_ data:PictureData, idx:Int) -> UserListItemData {
        self.albumData = AlbumListItemData().setData(data, idx: 0)
        if let user = data.user {
            self.userProfile = UserProfile().setData(data: user)
        }
        self.subImagePath = data.pets?.first?.pictureUrl
        self.date = data.createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")?.toDateFormatter(dateFormat: "EEEE, MMMM d, yyyy")
        return self
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
                UserProfileItem(
                    data: user,
                    subImagePath: self.data.subImagePath,
                    date: self.data.date,
                    action:self.moveUser
                )
                .padding(.vertical, Dimen.margin.regularExtra)
                .padding(.horizontal, Dimen.app.pageHorinzontal)
            }
            if let walkData = self.data.walkData{
                WalkListDetailItem(data: walkData, imgSize: self.imgSize)
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



