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
    private(set) var userProfile:UserProfile? = nil
    private(set) var subImagePath:String? = nil
    private(set) var date:String? = nil
   
    
    func setData(_ data:MissionData, idx:Int) -> UserListItemData {
        self.walkData = WalkListItemData().setData(data, idx: 0, isMine: false)
        if let user = data.user {
            self.userProfile = UserProfile().setData(data: user)
        }
        self.subImagePath = data.pets?.first?.pictureUrl
        self.contentID = data.missionId?.description ?? ""
        self.date = data.createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")?.toDateFormatter(dateFormat: "EEEE, MMMM d, yyyy")
        return self
    }
}

struct UserListItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    let data:UserListItemData
    let imgSize:CGSize
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HorizontalProfile(
                type: .multi(imgPath: self.data.subImagePath),
                sizeType: .small,
                funcType: .addFriend,
                imagePath: self.data.userProfile?.imagePath,
                name: self.data.userProfile?.nickName,
                date: self.data.date,
                gender: self.data.userProfile?.gender,
                age: self.data.userProfile?.birth?.toAge(),
                isSelected: false
            ){
                
            }
            .onTapGesture {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.user)
                        .addParam(key: .id, value:self.data.userProfile?.userId)
                )
            }
            if let walkData = self.data.walkData{
                WalkListDetailItem(data: walkData, imgSize: self.imgSize)
            }
        }
    }
}



