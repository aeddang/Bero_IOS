//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
class ChatRoomListItemData:InfinityData, ObservableObject{
    private(set) var roomId:Int = -1
    private(set) var profileImagePath:String? = nil
    private(set) var title:String? = nil
    private(set) var contents:String? = nil
    private(set) var date:Date? = nil
    private(set) var viewDate:String? = nil
    private(set) var unreadCount:Int = 0
    private(set) var userId:String? = nil
    private(set) var lv:Int? = nil
    fileprivate(set) var isRead:Bool = false
    @Published var isDelete:Bool = false
    func setData(_ data:ChatRoomData, idx:Int) -> ChatRoomListItemData {
        self.index = idx
        self.profileImagePath = data.receiverProfile
        self.roomId = data.chatRoomId ?? -1
        self.title = data.title
        self.contents = data.desc
        self.unreadCount = data.unreadCnt ?? 0
        self.isRead = self.unreadCount == 0
        self.userId = data.receiver
        self.lv = data.receiverLevel
        let date = data.updatedAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss") ?? data.createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
        let viewDate = date?.sinceNowDate(dateFormat:"MMMM d, yyyy")
        self.date = date
        self.viewDate = viewDate
        return self
    }
}

struct ChatRoomListItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var data:ChatRoomListItemData
    @Binding var isEdit:Bool
    @State var isRead:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(spacing: Dimen.margin.thin){
                HorizontalProfile(
                    type: .pet,
                    sizeType: .small,
                    funcType: self.isRead ? nil : .view("N"),   // .view(self.data.unreadCount.description),
                    imagePath: self.data.profileImagePath,
                    lv:self.data.lv,
                    name: self.data.title,
                    date: self.data.viewDate,
                    description: self.data.contents,
                    isSelected: false,
                    useBg: false
                ){ type in
                    
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.user)
                            .addParam(key: .id, value:self.data.userId)
                    )
                }
                .padding(.vertical, Dimen.margin.regularExtra)
                .onTapGesture {
                    if !self.isRead {
                        self.isRead = true
                        self.data.isRead = true
                        self.dataProvider.requestData(q: .init(type: .readChatRoom(roomId:self.data.roomId), isOptional: true))
                    }
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.chatRoom)
                            .addParam(key: .data, value:self.data)
                    )
                }
                if self.isEdit {
                    CircleButton(
                        type: .icon(Asset.icon.exit),
                        isSelected: false,
                        activeColor: Color.brand.primary
                    ){ _ in
                        self.delete()
                    }
                }
            }
        }
        .onAppear(){
            self.isRead = self.data.isRead
        }
    }
    
    private func delete(){
        self.appSceneObserver.sheet = .select(
            String.alert.chatRoomDeleteConfirm,
            String.alert.chatRoomDeleteConfirmText,
            [String.app.cancel,String.button.delete],
            isNegative: true
        ){ idx in
                if idx == 1 {
                    self.dataProvider.requestData(q: .init(type: .deleteChatRoom(roomId:self.data.roomId)))
                }
        }
    }
}



