//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
class WalkListItemData:InfinityData{
    private(set) var imagePath:String? = nil
    private(set) var type:MissionApi.Category = .all
    private(set) var title:String? = nil
    private(set) var description:String? = nil
    private(set) var pets:[PetProfile] = []
    func setData(_ data:MissionData, idx:Int, isMine:Bool) -> WalkListItemData {
        self.index = idx
        self.imagePath = data.pictureUrl
        self.contentID = data.missionId?.description ?? ""
        self.title = data.title
        self.description = data.description
        if let datas = data.pets {
            self.pets = datas.map{ PetProfile(data:$0, isMyPet: isMine) }
        }
        self.type = MissionApi.Category.getCategory(data.missionType) ?? .all
        return self
    }
}


struct WalkListItem: PageComponent{
    let data:WalkListItemData
    let imgSize:CGSize
    var action: (() -> Void) 
    var body: some View {
        ListItem(
            id: self.data.id,
            imgSize: self.imgSize,
            title: self.data.title,
            subTitle: self.data.description,
            icon: self.data.type.icon,
            iconText: self.data.type.text,
            move:self.action
        )
    }
}



