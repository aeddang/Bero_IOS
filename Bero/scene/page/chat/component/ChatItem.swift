//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
class ChatItemData:InfinityData, ObservableObject{
    private(set) var chatId:Int = -1
    private(set) var isMe:Bool = false
    private(set) var contents:String = ""
    private(set) var date:Date? = nil
    fileprivate(set) var isRead:Bool = false
    @Published var isDelete:Bool = false
    func setData(_ data:ChatData, me:String, idx:Int) -> ChatItemData {
        self.chatId = data.chatId ?? -1
        self.isMe = data.sender == me
        self.contents = data.contents ?? ""
        self.isRead = data.isRead ?? false
        self.isDelete = data.isDeleted ?? false
        self.date = data.createdAt?.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
        return self
    }
}

struct ChatItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var data:ChatItemData
    @State var isDeleted:Bool = false
    var body: some View {
        VStack(alignment: self.data.isMe ? .trailing : .leading, spacing: 0){
            Spacer().modifier(MatchHorizontal(height: 0))
            HStack(alignment:.bottom, spacing: Dimen.margin.micro){
                if self.data.isMe, let date = self.data.date {
                    Text( date.toDateFormatter(dateFormat: "hh:mm a") )
                        .modifier(LightTextStyle(
                            size: Font.size.tiny,
                            color:  Color.app.grey300))
                }
                Text( self.isDeleted ? String.pageText.chatRoomDeletedMessage : self.data.contents )
                    .modifier(RegularTextStyle(
                        size: Font.size.thin,
                        color: self.data.isMe ? Color.app.white : Color.app.black))
                    .padding(.vertical, Dimen.margin.micro)
                    .padding(.horizontal, Dimen.margin.thin)
                    .multilineTextAlignment(self.data.isMe ? .trailing : .leading)
                    .background(self.data.isMe ? Color.brand.primary : Color.app.grey50)
                    .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.medium))
                if !self.data.isMe , let date = self.data.date {
                    Text( date.toDateFormatter(dateFormat: "hh:mm a") )
                        .modifier(LightTextStyle(
                            size: Font.size.tiny,
                            color:  Color.app.grey300))
                }
            }
        }
        .padding(.leading,  Dimen.profile.thin )
        .onLongPressGesture {
            if !self.data.isMe {return}
            self.delete()
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            switch res.type {
            case .deleteChat(let id):
                if self.data.chatId == id{
                    self.data.isDelete = true
                    self.isDeleted = true
                }
          
            default : break
            }
        }
        .onAppear{
            self.isDeleted = self.data.isDelete
        }
    }
    
    private func delete(){
        self.appSceneObserver.sheet = .select(
            String.alert.chatDeleteConfirm,
            String.alert.chatDeleteConfirmText,
            [String.app.cancel,String.button.delete]){ idx in
                if idx == 1 {
                    self.dataProvider.requestData(q: .init(type: .deleteChat(chatId:self.data.chatId)))
                }
        }
    }
}



