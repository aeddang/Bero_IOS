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

class AlbumListItemData:InfinityData, ObservableObject{
    private(set) var imagePath:String? = nil
    private(set) var thumbIagePath:String? = nil
    @Published private(set) var isLike:Bool = false
    @Published private(set) var likeCount:Double = 0
    private(set) var pictureId:Int = -1
    func setData(_ data:PictureData, idx:Int) -> AlbumListItemData{
        self.index = idx
        self.imagePath = data.pictureUrl
        self.thumbIagePath = data.smallPictureUrl
        self.pictureId = data.pictureId ?? -1
        self.isLike = data.isChecked ?? false
        self.likeCount = data.thumbsupCount ?? 0
        return self
    }
    
    @discardableResult
    func updata(isLike:Bool) -> AlbumListItemData{
        if isLike != self.isLike {
            self.likeCount = isLike ? self.likeCount+1 : self.likeCount-1
            self.isLike = isLike
        }
        return self
    }
}

struct AlbumListItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var data:AlbumListItemData
    var user:User? = nil
    let imgSize:CGSize
    
    @State var isLike:Bool = false
    @State var likeCount:Double = 0
    var body: some View {
        ListItem(
            id: self.data.id,
            imagePath: self.data.thumbIagePath,
            imgSize: self.imgSize,
            likeCount: self.likeCount,
            isLike: self.isLike,
            likeSize: .small,
            action:{
                self.dataProvider.requestData(
                    q: .init( type: .updateAlbumPicture(pictureId: self.data.pictureId , isLike: !self.data.isLike)))
            },
            move: {
                self.pagePresenter.openPopup( 
                    PageProvider.getPageObject(.album)
                        .addParam(key: .data, value: self.user)
                        .addParam(key: .id, value: self.data.pictureId)
                )
            }
        )
        .onReceive(self.data.$isLike) { isLike in
            self.isLike = isLike
        }
        .onReceive(self.data.$likeCount) { value in
            self.likeCount = value
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAlbumPicture(let pictureId, let isLike): self.updated(pictureId, isLike: isLike)
            default : break
            }
        }
    }
    private func updated(_ id:Int, isLike:Bool){
        if self.data.pictureId == id {
            self.data.updata(isLike: isLike)
        }
    }
}

struct AlbumListDetailItem: PageComponent{
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var data:AlbumListItemData
    let imgSize:CGSize
    
    @State var isLike:Bool = false
    @State var likeCount:Double = 0
    var body: some View {
        ListDetailItem(
            id: self.data.id,
            imagePath: self.data.imagePath,
            imgSize: self.imgSize,
            likeCount: self.likeCount,
            isLike: self.isLike,
            likeSize: .small,
            action:{
                self.dataProvider.requestData(
                    q: .init( type: .updateAlbumPicture(pictureId: self.data.pictureId , isLike: !self.data.isLike)))
            }
        )
        .onReceive(self.data.$isLike) { isLike in
            self.isLike = isLike
        }
        .onReceive(self.data.$likeCount) { value in
            self.likeCount = value
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAlbumPicture(let pictureId, let isLike): self.updated(pictureId, isLike: isLike)
            default : break
            }
        }
        .onAppear(){
            self.isLike = self.data.isLike
            self.likeCount = self.data.likeCount
        }
    }
    private func updated(_ id:Int, isLike:Bool){
        if self.data.pictureId == id {
            self.data.updata(isLike: isLike)
        }
    }
}



