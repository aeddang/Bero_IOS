//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

class BlockUserItemData:InfinityData, ObservableObject{
    private(set) var user:UserProfile = UserProfile()
    fileprivate(set) var isBlock:Bool = true
   
    func setData(_ data:UserData, idx:Int) -> BlockUserItemData {
        self.index = idx
        self.user = UserProfile().setData(data: data)
        return self
    }
}

struct BlockUserItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var data:BlockUserItemData
     
    var body: some View {
        HorizontalProfile(
            type: .user,
            sizeType: .small,
            funcType: .block(self.isBlock) ,
            imagePath: self.data.user.imagePath,
            name: self.data.user.nickName,
            gender: self.data.user.gender,
            age: self.data.user.birth?.toAge(),
            isSelected: false,
            useBg: true
        ){ type in
            switch type {
            case .block : self.block()
            default : self.block()
            }
        }
        .onTapGesture {
            self.block()
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            switch res.type {
            case .blockUser(let userId, let isBlock) :
                if self.data.user.userId == userId {
                    withAnimation{ self.isBlock = isBlock }
                    self.data.isBlock = isBlock
                }
            default : break
            }
        }
        
        .onAppear{
            self.isBlock = self.data.isBlock
        }
    }
    @State var isBlock:Bool = true
    
    private func block(){
        let value = !self.isBlock
        
        self.appSceneObserver.sheet = .select(
            value ? String.alert.blockUserConfirm : String.alert.unblockUserConfirm,
            nil,
            [String.app.cancel,value ? String.button.block : String.button.unblock],
            isNegative: value 
        ){ idx in
                if idx == 1 {
                    self.dataProvider.requestData(q: .init(type: .blockUser(userId: self.data.user.userId, isBlock: value)))
                }
            }
    }
}


