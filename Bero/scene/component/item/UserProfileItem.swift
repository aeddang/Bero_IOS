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
    var subImagePath:String? = nil
    var date:String? = nil
    var action: (() -> Void)? = nil
    var body: some View {
        HorizontalProfile(
            type: .multi(imgPath: self.subImagePath),
            sizeType: .small,
            funcType: self.dataProvider.user.isSameUser(self.data)
                ? nil
                : self.status == .friend ? .send : .addFriend ,
            imagePath: self.data.imagePath,
            name: self.data.nickName,
            gender: self.date == nil ? self.data.gender : nil,
            age: self.date == nil ? self.data.birth?.toAge() : nil,
            description: self.date,
            isSelected: false,
            useBg: false
        ){ type in
            
            switch type {
            case .addFriend : self.requestFriend()
            case .send : self.appSceneObserver.event = .sendChat(userId: self.data.userId)
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
    private func requestFriend(){
        let id = self.data.userId
        self.dataProvider.requestData(q: .init(id: id, type: .requestFriend(userId: id)))
    }
}



