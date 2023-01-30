//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct FriendListItemDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 3
    var datas:[FriendListItemData] = []
    var isFull = false
    var index:Int = -1
}

class FriendListItemData:InfinityData{
    private(set) var imagePath:String? = nil
    private(set) var subImagePath:String? = nil
    private(set) var name:String? = nil
    private(set) var petName:String? = nil
    private(set) var text:String? = nil
    private(set) var userId:String? = nil
    func setData(_ data:MissionData, idx:Int) -> FriendListItemData{
        self.index = idx
        self.imagePath = data.pets?.first?.pictureUrl
        self.subImagePath = data.user?.pictureUrl
        self.userId = data.user?.userId ?? ""
        let petName = data.pets?.first?.name
        let userName = data.user?.name
        if let pet = petName , let user = userName {
            self.text = pet + " & " + user
        } else if let pet = petName {
            self.text = pet
        } else if let user = userName {
            self.text = user
        }
        return self
    }
    
    func setData(_ data:FriendData, idx:Int, type:FriendStatus) -> FriendListItemData{
        self.index = idx
        self.imagePath = data.petImg
        self.subImagePath = data.userImg
        self.userId = data.refUserId
        let petName = data.petName
        let userName = data.userName
        self.petName = petName
        self.name = userName
        if let pet = petName , let user = userName {
            self.text = pet + " & " + user
        } else if let pet = petName {
            self.text = pet
        } else if let user = userName {
            self.text = user
        }
        return self
    }
}

struct FriendListItem: PageComponent{
    @EnvironmentObject var dataProvider:DataProvider
    let data:FriendListItemData
    let imgSize:CGFloat
    let isMe:Bool
    var status:FriendStatus? = nil
    var isHorizontal:Bool = true
    var action: (() -> Void)
    var body: some View {
        ZStack{
            if self.isHorizontal {
                FriendListItemBodyHorizontal(
                    data: self.data,
                    imgSize: self.imgSize,
                    isMe: self.isMe,
                    status: self.status,
                    currentStatus: self.currentStatus,
                    action: self.action)
            } else {
                FriendListItemBodyVertical(
                    data: self.data,
                    imgSize: self.imgSize,
                    isMe: self.isMe,
                    status: self.status,
                    currentStatus: self.currentStatus,
                    action: self.action)
            }
        }
        .onTapGesture {
            self.action()
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }

            switch res.type {
            case .requestFriend(let userId) :
                if self.data.userId == userId {
                    self.currentStatus = .requestFriend
                }
            case .acceptFriend(let userId) :
                if self.data.userId == userId {
                    self.currentStatus = .friend
                }
            case .rejectFriend(let userId), .deleteFriend(let userId) :
                if self.data.userId == userId {
                    self.currentStatus = .norelation 
                }
            default : break
            }
        }
        .onAppear{
            self.currentStatus = self.status
        }
    }
    
    @State var currentStatus:FriendStatus? = nil
}



struct FriendListItemBodyHorizontal: PageComponent{
    @EnvironmentObject var dataProvider:DataProvider
    let data:FriendListItemData
    let imgSize:CGFloat
    let isMe:Bool
    var status:FriendStatus? = nil
    var currentStatus:FriendStatus? = nil
    var action: (() -> Void)
    var body: some View {
        Button(action: {
            self.action()
        }) {
            MultiProfile(
                id: "",
                type: .pet,
                circleButtontype: .image(self.data.subImagePath ?? ""),
                userId: self.isMe ? self.data.userId : nil,
                friendStatus: self.currentStatus,
                image: nil,
                imagePath: self.data.imagePath,
                imageSize: self.imgSize,
                name: self.data.text,
                buttonAction: self.action
            )
        }
    }
}


struct FriendListItemBodyVertical: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    let data:FriendListItemData
    let imgSize:CGFloat
    let isMe:Bool
    var status:FriendStatus? = nil
    var currentStatus:FriendStatus? = nil
    var action: (() -> Void)
    var body: some View {
        ZStack{
            HorizontalProfile(
                type: .multi(imgPath: self.data.subImagePath),
                sizeType: .small,
                funcType: .moreFunc,   // .view(self.data.unreadCount.description),
                userId: self.isMe ? self.data.userId : nil,
                friendStatus: self.currentStatus,
                imagePath: self.data.imagePath,
                name: self.data.petName,
                description: self.data.name,
                isSelected: false,
                useBg: false
            ){ type in
                switch type {
                case .moreFunc : self.more()
                default : self.action()
                }
            }
        }
        .padding(.vertical, Dimen.margin.thin)
        
    }
    
    private func more(){
        let datas:[String] = [
            String.button.block,
            String.button.accuseUser
        ]
        let icons:[String?] = [
            Asset.icon.block,
            Asset.icon.notice
        ]
       
        self.appSceneObserver.radio = .select((self.tag, icons, datas), title: String.alert.supportAction){ idx in
            guard let idx = idx else {return}
            switch idx {
            case 0 :self.block()
            case 1 :self.accuse()
            default : break
            }
        }
    }
    
    
    private func block(){
        self.appSceneObserver.sheet = .select(
            String.alert.blockUserConfirm,
            nil,
            [String.app.cancel,String.button.block],
            isNegative: true){ idx in
                if idx == 1 {
                    self.dataProvider.requestData(q: .init(type: .blockUser(userId: self.data.userId  ?? "", isBlock: true)))
                }
        }
    }
    
    private func accuse(){
        self.appSceneObserver.sheet = .select(
            String.alert.accuseUserConfirm,
            String.alert.accuseUserConfirmText,
            [String.app.cancel,String.button.accuse],
            isNegative: true){ idx in
                if idx == 1 {
                    self.dataProvider.requestData(q: .init(type: .sendReport(
                        reportType: .user , userId: self.data.userId 
                    )))
                }
        }
    }
    
}

