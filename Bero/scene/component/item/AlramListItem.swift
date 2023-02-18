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
    private(set) var type:AlarmListItem.AlarmType = .friend
    private(set) var imagePath:String? = nil
    private(set) var title:String? = nil
    private(set) var description:String? = nil
    private(set) var pet:PetProfile? = nil
    @Published var isDelete:Bool = false
    func setDummy(_ idx:Int) -> AlarmListItemData {
        self.index = idx
        self.pet = PetProfile()
        self.title = "hjsgshcjascbkascbksa"
        self.description = "dskjcsdkjcbsakjbcksajcb"
        self.imagePath = "qwdsdc"
        return self
    }
}

extension AlarmListItem{
    enum AlarmType{
        case chat, like, friend
        var icon:String{
            switch self {
            case .chat : return Asset.icon.chat
            case .like: return Asset.icon.favorite_on
            case .friend: return Asset.icon.human_friends
            }
        }
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
                imagePath: self.data.pet?.imagePath,
                name: self.data.title,
                description: self.data.description,
                withImagePath: self.data.imagePath,
                isSelected: false
            ){ _ in
                
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
        case .friend :
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.friend)
                    .addParam(key: .data, value: self.dataProvider.user)
                    .addParam(key: .type, value: FriendList.ListType.requested)
                    .addParam(key: .isEdit, value: true)
            )
        case .chat :
            self.pagePresenter.changePage(
                PageProvider.getPageObject(.chat)
            )
            /*
             self.pagePresenter.openPopup(
             PageProvider.getPageObject(.chatRoom)
             .addParam(key: .data, value:ChatRoomListItemData())
             )
             */
        case .like :
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.walkInfo)
                    .addParam(key: .data, value: User())
                    .addParam(key: .id, value: "walkId")
            )
            break
        }
    }
}





