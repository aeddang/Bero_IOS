//
//  AlarmListItem.swift
//  Bero
//
//  Created by JeongCheol Kim on 2023/02/18.
//

import Foundation

import Foundation
import SwiftUI



class AlarmListItemData:InfinityData, ObservableObject{
    private(set) var type:MiscApi.AlarmType? = nil
    private(set) var imagePath:String? = nil
    private(set) var title:String? = nil
    private(set) var description:String? = nil
    private(set) var user:User? = nil
    private(set) var pet:PetProfile? = nil
    private(set) var album:AlbumListItemData? = nil
    @Published var isDelete:Bool = false
    func setDummy(_ idx:Int) -> AlarmListItemData {
        self.index = idx
        self.pet = PetProfile()
        self.title = "hjsgshcjascbkascbksa"
        self.description = "dskjcsdkjcbsakjbcksajcb"
        self.imagePath = "qwdsdc"
        return self
    }
    
    func setData(_ data:AlarmData , idx:Int) -> AlarmListItemData {
        self.index = idx
        self.type = MiscApi.AlarmType.getType(data.alarmType)
        if let user = data.user {
            self.user = User().setData(data: user)
        }
        if let pet = data.pet {
            self.pet = PetProfile(data: pet, userId: self.user?.userId)
        }
        if let album = data.album {
            self.album = AlbumListItemData().setData(album)
        }
        self.title = data.title
        self.description = data.contents
        self.imagePath = self.album?.thumbIagePath
        return self
    }
}

struct AlarmListItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    let data:AlarmListItemData
    @Binding var isEdit:Bool
    @State var isDelete:Bool = false
    var body: some View {
        HStack{
            HorizontalProfile(
                id: "",
                type: .pet,
                color: Color.brand.primary,
                imagePath: self.data.pet?.imagePath ?? self.data.user?.currentProfile.imagePath,
                name: self.data.title,
                description: self.data.description,
                withImagePath: self.data.imagePath,
                isSelected: false
            ){ type in
                switch type {
                case nil :
                    self.moveUser()
                case .view :
                    self.move()
                default :
                    self.move()
                }
            }
            .onTapGesture(){
                self.move()
            }
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
        .onReceive(self.data.$isDelete) { isDelete in
            self.isDelete = isDelete
        }
    }
    
    private func move(){
        switch self.data.type {
        case .Friend :
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.friend)
                    .addParam(key: .data, value: self.dataProvider.user)
                    .addParam(key: .type, value: FriendList.ListType.requested)
                    .addParam(key: .isEdit, value: true)
            )
        case .User :
            guard let userId = self.data.user?.userId else {return}
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.user)
                    .addParam(key: .id, value: userId)
            )
        case .Chat :
            self.pagePresenter.changePage(
                PageProvider.getPageObject(.chat)
            )

        case .Album :
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.picture)
                    .addParam(key: .title, value: String.pageTitle.alarm)
                    .addParam(key: .subText, value: self.data.title ?? self.data.description)
                    .addParam(key: .data, value: self.data.album)
                    .addParam(key: .subData, value: self.data.user)
                    .addParam(key: .userData, value: self.dataProvider.user)
            )
        default :
            break
        }
    }
    private func moveUser(){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.user)
                .addParam(key: .data, value: self.data.user)
                .addParam(key: .id, value: self.data.pet?.userId)
                .addParam(key: .isEdit, value: true)
        )
    }
}





