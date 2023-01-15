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
    private(set) var originData:WalkData? = nil
    private(set) var walkPath:WalkPath? = nil
    func setData(_ data:WalkData, idx:Int) -> WalkListItemData {
        self.index = idx
        self.originData = data
        if let locs = data.locations {
            self.walkPath = WalkPath().setData(locs)
        }
        self.imagePath = self.walkPath?.picture?.smallPictureUrl
        self.title = WalkManager.viewDistance(data.distance ?? 0) + " " + String.app.walk
        
        if let datas = data.pets {
            self.pets = zip(0..<datas.count, datas).map{ idx, profile in PetProfile(data: profile, index: idx)}
        }
        self.type = .walk
        return self
    }
    /*
    func setData(_ data:MissionData, idx:Int) -> WalkListItemData {
        self.index = idx
        
        self.imagePath = data.pictureUrl
        self.contentID = data.missionId?.description ?? ""
        self.title = WalkManager.viewDistance(data.distance ?? 0) + " " + String.app.walk
        if let place = data.place {
            self.description = String.app.near + " " + (place.name ?? "")
        }
        if let datas = data.pets {
            self.pets = zip(0..<datas.count, datas).map{ idx, profile in PetProfile(data: profile, index: idx)}
        }
        self.type = MissionApi.Category.getCategory(data.missionType) ?? .all
        return self
    }
    */
}


struct WalkListItem: PageComponent{
    let data:WalkListItemData
    let imgSize:CGSize
    var action: (() -> Void)? = nil
    var body: some View {
        ListItem(
            id: self.data.id,
            imagePath: self.data.imagePath,
            emptyImage: Asset.noImg16_9,
            imgSize: self.imgSize,
            title: self.data.title,
            subTitle: self.data.description,
            icon: self.data.type.icon,
            iconText: self.data.type.text,
            pets: self.data.pets,
            iconAction: self.action,
            move:self.action
        )
    }
}



