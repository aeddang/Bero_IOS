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
        self.imagePath = data.userImg
        self.subImagePath = data.petImg
        self.userId = data.refUserId
        let petName = data.petName
        let userName = data.userName
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
    var status:FriendStatus? = nil
    var action: (() -> Void)
    var body: some View {
        
        VStack(spacing: Dimen.margin.tiny){
            Button(action: {
                self.action()
            }) {
                MultiProfile(
                    id: "",
                    type: .pet,
                    circleButtontype: .image(self.data.subImagePath ?? ""),
                    image: nil,
                    imagePath: self.data.imagePath,
                    imageSize: self.imgSize,
                    name: self.data.text,
                    buttonAction: self.action
                )
            }
            if let status = self.currentStatus {
                HStack( spacing: Dimen.margin.micro){
                    ForEach(status.buttons, id:\.rawValue){ btn in
                        FriendButton(
                            userId: self.data.userId,
                            type: btn,
                            size:Dimen.button.light,
                            radius: Dimen.radius.regular,
                            textSize: Font.size.tiny
                        )
                    }
                }
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
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



