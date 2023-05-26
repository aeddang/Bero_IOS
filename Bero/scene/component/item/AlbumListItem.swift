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
    @Published private(set) var isExpose:Bool = false
    @Published private(set) var likeCount:Double = 0
    @Published var isDelete:Bool = false
    private(set) var pictureId:Int = -1
    private(set) var walkId:Int? = nil
    private(set) var type:MissionApi.Category? = nil
    func setData(_ data:PictureData, idx:Int = -1) -> AlbumListItemData{
        self.index = idx
        self.imagePath = data.pictureUrl
        self.thumbIagePath = data.smallPictureUrl
        self.pictureId = data.pictureId ?? -1
        self.isLike = data.isChecked ?? false
        self.isExpose = data.isExpose ?? false
        self.likeCount = data.thumbsupCount ?? 0
        self.walkId = data.referenceId?.toInt()
        if self.walkId != nil {
            self.type = .walk
        }
        return self
    }
        
    @discardableResult
    func updata(isLike:Bool?, isExpose:Bool?) -> AlbumListItemData{
        if isLike != self.isLike, let isLike = isLike {
            self.likeCount = isLike ? self.likeCount+1 : self.likeCount-1
            self.isLike = isLike
        }
        if isExpose != self.isExpose, let isExpose = isExpose {
            self.isExpose = isExpose
        }
        return self
    }
}

struct AlbumListItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var data:AlbumListItemData
    var user:User? = nil
    var pet:PetProfile? = nil
    let imgSize:CGSize
    @Binding var isEdit:Bool
    @State var isDelete:Bool = false
    @State var isLike:Bool = false
    @State var likeCount:Double = 0
    var body: some View {
        ZStack(alignment: .topTrailing){
            ListItem(
                id: self.data.id,
                imagePath: self.data.thumbIagePath,
                imgSize: self.imgSize,
                icon: self.data.type?.icon,
                likeCount: self.likeCount,
                isLike: self.isLike,
                likeSize: .small,
                iconAction:{
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.walkInfo)
                            .addParam(key: .id, value: self.data.walkId)
                            .addParam(key: .data, value: self.user)
                    )
                },
                action:{
                    self.dataProvider.requestData(
                        q: .init( type: .updateAlbumPicture(pictureId: self.data.pictureId , isLike: !self.data.isLike)))
                },
                move: {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.pictureViewer)
                            .addParam(key: .data, value: data)
                        )
                    /*
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.album)
                            .addParam(key: .data, value: self.user)
                            .addParam(key: .subData, value: self.pet)
                            .addParam(key: .id, value: self.data.pictureId)
                    )*/
                }
            )
            if self.isEdit {
                CircleButton(
                    type: .icon(Asset.icon.delete),
                    isSelected: self.isDelete,
                    activeColor: Color.brand.primary
                ){ _ in
                    self.data.isDelete.toggle()
                }
                .padding(.all, Dimen.margin.thin)
            }
        }
        .onReceive(self.data.$isLike) { isLike in
            self.isLike = isLike
        }
        .onReceive(self.data.$likeCount) { value in
            self.likeCount = value
        }
        .onReceive(self.data.$isDelete) { isDelete in
            self.isDelete = isDelete
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAlbumPicture(let pictureId, let isLike, let isExpose): self.updated(pictureId, isLike: isLike, isExpose:isExpose)
            default : break
            }
        }
    }
    private func updated(_ id:Int, isLike:Bool?, isExpose:Bool?){
        if self.data.pictureId == id {
            self.data.updata(isLike: isLike, isExpose: isExpose)
        }
    }
}

struct AlbumListDetailItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var data:AlbumListItemData
    var user:User? = nil
    var userProfile:UserProfile? = nil
    var pet:PetProfile? = nil
    let imgSize:CGSize
    var isOriginSize:Bool = false
    @Binding var isEdit:Bool
    @State var isDelete:Bool = false
    @State var isLike:Bool = false
    @State var likeCount:Double = 0
    @State var isExpose:Bool = false
    var body: some View {
        ZStack(alignment: .topTrailing){
            ListDetailItem(
                id: self.data.id,
                imagePath: self.data.imagePath,
                imgSize: self.imgSize,
                icon: self.data.type?.icon,
                likeCount: self.likeCount,
                isLike: self.isLike,
                likeSize: .small,
                isShared: self.user?.isMe == true ? self.isExpose : nil,
                isOriginSize: self.isOriginSize,
                iconAction:{
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.walkInfo)
                            .addParam(key: .id, value: self.data.walkId)
                            .addParam(key: .data, value: self.user ?? self.userProfile)
                    )
                },
                likeAction:{
                    self.dataProvider.requestData(
                        q: .init( type: .updateAlbumPicture(pictureId: self.data.pictureId , isLike: !self.data.isLike)))
                },
                shareAction: {
                    self.dataProvider.requestData(
                        q: .init( type: .updateAlbumPicture(pictureId: self.data.pictureId , isExpose: !self.data.isExpose)))
                }
            )
            
            if self.isEdit {
                CircleButton(
                    type: .icon(Asset.icon.delete),
                    isSelected: self.isDelete,
                    activeColor: Color.brand.primary
                ){ _ in
                    self.data.isDelete.toggle()
                }
                .padding(.all, Dimen.margin.thin)
            }
            
        }
        .onReceive(self.data.$isLike) { isLike in
            self.isLike = isLike
        }
        .onReceive(self.data.$likeCount) { value in
            self.likeCount = value
        }
        .onReceive(self.data.$isExpose) { value in
            self.isExpose = value
        }
        .onReceive(self.data.$isDelete) { isDelete in
            self.isDelete = isDelete
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAlbumPicture(let pictureId, let isLike, let isExpose): self.updated(pictureId, isLike: isLike, isExpose:isExpose)
            default : break
            }
        }
        .onAppear(){
            self.isLike = self.data.isLike
            self.likeCount = self.data.likeCount
            self.isDelete = self.data.isDelete
            self.isExpose = self.data.isExpose
        }
    }
    private func updated(_ id:Int, isLike:Bool?, isExpose:Bool?){
        if self.data.pictureId == id {
            self.data.updata(isLike: isLike, isExpose: isExpose)
            if let expose = isExpose {
                self.appSceneObserver.event = .toast(expose ? String.alert.exposed : String.alert.unExposed)
            }
        }
    }
}



