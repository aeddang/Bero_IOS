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
    private(set) var refUserId:String = ""
    fileprivate(set) var isBlock:Bool = true
   
    func setData(_ data:UserData, idx:Int) -> BlockUserItemData {
        self.index = idx
        self.user = UserProfile().setData(data: data)
        self.refUserId = data.refUserId ?? ""
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
            name: self.data.user.nickName ?? self.data.refUserId,
            description: self.data.user.date,
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
                if self.data.refUserId == userId {
                    withAnimation{ self.isBlock = isBlock }
                    self.data.isBlock = isBlock
                }
            default : break
            }
        }
        
        .onAppear{
            self.isBlock = self.data.isBlock
            self.userName = self.data.user.nickName ?? ""
        }
    }
    @State var userName:String = ""
    @State var isBlock:Bool = true
    
    private func block(){
        let value = !self.isBlock
        
        self.appSceneObserver.sheet = .select(
            value ? String.alert.blockUserConfirm.replace(self.userName) : String.alert.unblockUserConfirm.replace(self.userName),
            value ? String.alert.blockUserConfirmText : nil,
            [String.app.cancel,value ? String.button.block : String.button.unblock],
            isNegative: value 
        ){ idx in
                if idx == 1 {
                    self.dataProvider.requestData(q: .init(type: .blockUser(userId: self.data.refUserId, isBlock: value)))
                }
            }
    }
}


