//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct AlbumListItemDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var count:Int = 2
    var datas:[AlbumListItemData] = []
    var isFull = false
    var index:Int = -1
}

class AlbumListItemData:InfinityData{
    private(set) var imagePath:String? = nil
    private(set) var isLike:Bool = false
    private(set) var likeCount:Double = 0
    func setData(_ data:MissionData, idx:Int, isMine:Bool) -> AlbumListItemData{
        self.index = idx
        self.imagePath = data.pictureUrl
        self.contentID = data.missionId?.description ?? ""
        return self
    }
    
    func setData(_ data:PictureData, idx:Int, isMine:Bool) -> AlbumListItemData{
        self.index = idx
        self.imagePath = data.pictureUrl
        self.contentID = data.pictureId?.description ?? ""
        self.isLike = data.isChecked ?? false
        self.likeCount = data.thumbsupCount ?? 0
        return self
    }
}

struct AlbumListItem: PageComponent{
    let data:AlbumListItemData
    let imgSize:CGSize

    var body: some View {
        ListItem(
            id: self.data.id,
            imagePath: self.data.imagePath,
            imgSize: self.imgSize,
            likeCount: self.data.likeCount,
            isLike: self.data.isLike,
            likeSize: .small,
            action:{},
            move:{}
        )
        
    }
}



