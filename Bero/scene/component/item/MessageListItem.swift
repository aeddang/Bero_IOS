//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
class MessageListItemData:InfinityData, ObservableObject{
    private(set) var userProfile:UserProfile? = nil
    private(set) var chatId:Int = -1
    private(set) var subImagePath:String? = nil
    private(set) var title:String? = nil
    private(set) var contents:String? = nil
    private(set) var date:Date? = nil
    fileprivate(set) var isRead:Bool = false
    @Published var isDelete:Bool = false
    func setData(_ data:ChatData, idx:Int) -> MessageListItemData {
        if let user = data.senderUser {
            self.userProfile = UserProfile().setData(data: user)
        }
        self.subImagePath = data.senderPets?.first?.pictureUrl
        self.chatId = data.chatId ?? -1
        self.contents = data.contents
        self.isRead = data.isRead ?? false
        self.date = data.createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
        return self
    }
}

struct MessageListItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var data:MessageListItemData
    @Binding var isEdit:Bool
    @State var isRead:Bool = false
    @State var isExpand:Bool = false
    @State var isDelete:Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack(spacing: Dimen.margin.thin){
                HorizontalProfile(
                    type: .multi(imgPath: self.data.subImagePath),
                    sizeType: .small,
                    funcType: self.isRead ? nil : .view("N"),
                    imagePath: self.data.userProfile?.imagePath,
                    name: self.data.userProfile?.nickName,
                    date: self.data.date,
                    gender : self.isExpand ? self.data.userProfile?.gender : nil,
                    age : self.isExpand ? self.data.userProfile?.birth?.toAge() : nil,
                    description: self.isExpand ? nil : self.data.contents,
                    isSelected: false
                ){ type in
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.user)
                            .addParam(key: .id, value:self.data.userProfile?.userId)
                    )
                }
                .onTapGesture {
                    if !self.isRead {
                        self.isRead = true
                        self.data.isRead = true
                        self.dataProvider.requestData(q: .init(type: .readChat(chatId: self.data.chatId), isOptional: true))
                    }
                    withAnimation{
                        self.isExpand.toggle()
                    }
                }
                if self.isEdit {
                    CircleButton(
                        type: .icon(Asset.icon.delete),
                        isSelected: self.isDelete,
                        activeColor: Color.brand.primary
                    ){ _ in
                        self.data.isDelete.toggle()
                    }
                }
            }
            if self.isExpand && !self.isEdit{
                VStack(alignment: .trailing, spacing: Dimen.margin.tiny){
                    VStack(alignment:.leading, spacing:0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        Text(self.data.contents ?? "")
                            .modifier(RegularTextStyle(
                                size: Font.size.thin,
                                color: Color.app.grey500
                            ))
                            .multilineTextAlignment(.leading)
                            
                    }
                    if let userId = self.data.userProfile?.userId {
                        TextButton(
                            defaultText: String.button.reply,
                            textModifier:TextModifier(
                                family:Font.family.medium,
                                size:Font.size.thin,
                                color: Color.brand.primary)
                        )
                        {_ in
                            self.appSceneObserver.event = .sendChat(userId: userId)
                        }
                    }
                }
                .padding(.all, Dimen.margin.thin)
                .background(Color.app.whiteDeepLight)
                .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.lightExtra))
                
            }
        }
        .onAppear(){
            self.isRead = self.data.isRead
            self.isExpand = false
            self.isDelete = self.data.isDelete
        }
        .onReceive(self.data.$isDelete) { isDelete in
            self.isDelete = isDelete
        }
    }
}



