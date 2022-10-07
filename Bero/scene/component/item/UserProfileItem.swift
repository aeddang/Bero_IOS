//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


struct UserProfileItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var data:UserProfile
    var postId:String? = nil
    var subImagePath:String? = nil
    var date:String? = nil
    var useBg:Bool = false
    var action: (() -> Void)? = nil
    var body: some View {
        HorizontalProfile(
            type: .multi(imgPath: self.subImagePath),
            sizeType: .small,
            funcType: self.dataProvider.user.isSameUser(self.data)
                ? nil
            : .moreFunc ,
            imagePath: self.data.imagePath,
            name: self.data.nickName,
            gender: self.date == nil ? self.data.gender : nil,
            age: self.date == nil ? self.data.birth?.toAge() : nil,
            description: self.date,
            isSelected: false,
            useBg: self.useBg
        ){ type in
            
            switch type {
            case .moreFunc : self.more()
            default : self.action?()
            }
        }
        .onTapGesture {
            self.action?()
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .requestFriend(let userId) :
                if self.data.userId == userId {
                    self.data.status = .requestFriend
                }
            default : break
            }
        }
        .onReceive(self.data.$status){st in
            self.status = st
        }
        .onAppear{
            self.status = self.data.status
        }
    }
    
    @State var status:FriendStatus = .norelation
    private func more(){
        
        let datas:[String] = [
            self.status == .friend ? String.button.chat : String.button.addFriend,
            //String.button.share,
            String.button.accuse
        ]
        let icons:[String?] = [
            self.status == .friend ? Asset.icon.chat : Asset.icon.add_friend,
            //Asset.icon.share,
            Asset.icon.notice
        ]
       
        self.appSceneObserver.radio = .select((self.tag, icons, datas)){ idx in
            guard let idx = idx else {return}
            switch idx {
            case 0 :
                if self.status == .friend {
                    self.sendMessage()
                } else {
                    self.requestFriend()
                }
                
            case 1 : self.accuse()
            default : break
            }
        }
    }
    
    private func requestFriend(){
        let id = self.data.userId
        self.dataProvider.requestData(q: .init(id: id, type: .requestFriend(userId: id)))
    }
    private func sendMessage(){
        let id = self.data.userId
        self.appSceneObserver.event = .sendChat(userId: id)
    }
    private func accuse(){
        if let post = self.postId {
            self.appSceneObserver.sheet = .select(
                String.alert.accuseAlbumConfirm,
                String.alert.accuseAlbumConfirmText,
                [String.app.cancel,String.button.accuse],
                isNegative: true){ idx in
                    if idx == 1 {
                        self.dataProvider.requestData(q: .init(type: .sendReport(
                            reportType: .user, postId: post , userId: self.data.userId
                        )))
                    }
                }
        } else {
            self.appSceneObserver.sheet = .select(
                String.alert.accuseUserConfirm,
                String.alert.accuseUserConfirmText,
                [String.app.cancel,String.button.accuseUser],
                isNegative: true){ idx in
                    if idx == 1 {
                        self.dataProvider.requestData(q: .init(type: .sendReport(
                            reportType: .user, postId: nil , userId: self.data.userId
                        )))
                    }
                }
        }
    }
}



