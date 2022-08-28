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
    func setData(_ data:MissionData, idx:Int) -> FriendListItemData{
        self.index = idx
        self.imagePath = data.pets?.first?.pictureUrl
        self.subImagePath = data.user?.pictureUrl
        self.contentID = data.user?.userId ?? "" 
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
}

struct FriendListItem: PageComponent{
    let data:FriendListItemData
    let imgSize:CGFloat
    var action: (() -> Void)
    var body: some View {
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
                name: self.data.text
            )
        }
    }
}



