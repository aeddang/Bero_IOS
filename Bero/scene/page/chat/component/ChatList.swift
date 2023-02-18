//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI
class ChatListDataSet:InfinityData{
    fileprivate(set) var date:Date? = nil
    fileprivate(set) var originDate:Date? = nil
    fileprivate(set) var isMe:Bool = false
    fileprivate(set) var datas:[ChatItemData] = []
    
}

struct ChatList: PageComponent{
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var userId:String
    var roomData:ChatRoomListItemData? = nil
    @Binding var userName:String?
    var body: some View {
        VStack(spacing:0){
            ZStack{
                if let pet = self.pet {
                    HorizontalProfile(
                        type: .pet,
                        sizeType: .small,
                        imagePath: pet.imagePath,
                        lv: self.user?.lv,
                        name: pet.name,
                        gender: pet.gender,
                        isNeutralized: pet.isNeutralized,
                        age: pet.birth?.toAge(),
                        breed: pet.breed,
                        useBg: false
                    )
                    
                } else if let user = self.user?.currentProfile {
                    HorizontalProfile(
                        type: .user,
                        sizeType: .small,
                        imagePath: user.imagePath,
                        lv: user.lv,
                        name: user.nickName,
                        gender: user.gender,
                        age: user.birth?.toAge(),
                        useBg: false
                    )
                }
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            .padding(.vertical, Dimen.margin.thin)
            .background(Color.app.orangeSub)
            .onTapGesture {
                self.move()
            }
            if self.isEmpty {
                EmptyItem(type: .myList)
                    .padding(.top, Dimen.margin.regularUltra)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                Spacer().modifier(MatchParent())
                
            } else {
                InfinityScrollView(
                    viewModel: self.infinityScrollModel,
                    axes: .vertical,
                    showIndicators : false,
                    marginTop:0,
                    marginBottom:Dimen.margin.medium,
                    marginHorizontal: 0,
                    spacing:Dimen.margin.regular,
                    isRecycle: true,
                    useTracking: true
                ){
                    
                    ForEach(self.chats) { data in
                        VStack(alignment: .center, spacing:0){
                            if let date = data.date {
                                Text( date.toDateFormatter(dateFormat: "EEEE, MMMM d, yyyy") )
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color:  Color.app.grey400))
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, Dimen.margin.regular)
                            }
                            if data.index == 0 {
                                Text( String.pageText.chatRoomText )
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color:  Color.app.grey300))
                                    .multilineTextAlignment(.center)
                                    .padding(.bottom, Dimen.margin.regular)
                            }
                            if !data.isMe {
                                if let pet = self.pet {
                                    HorizontalProfile(
                                        type: .pet,
                                        sizeType: .tiny,
                                        imagePath: pet.imagePath,
                                        name: pet.name,
                                        useBg: false
                                    )
                                } else {
                                    HorizontalProfile(
                                        type: .user,
                                        sizeType: .tiny,
                                        imagePath: self.user?.currentProfile.imagePath,
                                        name: self.user?.currentProfile.nickName,
                                        useBg: false
                                    )
                                }
                                
                            }
                            ForEach(data.datas.reversed() ) { chat in
                                ChatItem(data:chat)
                                    .padding(.bottom, Dimen.margin.tiny)
                            }
                        }
                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                        .padding(.top, Dimen.margin.regular)
                        .id(data.hashId)
                        .onAppear{
                            if data.index == (self.chats.count-1) {
                                self.infinityScrollModel.event = .bottom
                            }
                        }
                    }
                }
            }
            
        }
        .onReceive(self.infinityScrollModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .top : self.loadChat()
            //case .bottom : self.loadChat()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .reload :
                self.resetScroll()
                self.loadChat()
            default : break
            }
        }
        .onReceive (self.appObserver.$page) { iwg in
            guard let pageId = iwg?.page?.pageID else { return }
            switch pageId {
            case .chat :
                self.resetScroll()
                self.loadChat()
                if let id = self.roomData?.roomId {
                    self.dataProvider.requestData(q: .init(type: .readChatRoom(roomId:id), isOptional: true))
                }
            default: break
            }
            //self.appObserverMove(iwg)
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            switch res.type {
            case .getChats(let id, _ , _):
                if self.userId != id {return}
                self.loaded(res)
            case .sendChat(let id, let content):
                if self.userId != id {return}
                let data = res.data as? ChatData ?? ChatData(
                    contents:content,
                    createdAt: Date().toDateFormatter(dateFormat: "yyyy-MM-dd'T'HH:mm:ss"),
                    sender: self.dataProvider.user.snsUser?.snsID
                )
                self.insertChat(data: data)
                
            default : break
            }
            
        }
        .onAppear(){
            self.loadChat()
        }
    }
    
    @State var isEmpty:Bool = false
    @State var chats:[ChatListDataSet] = []
    @State var user:User? = nil
    @State var pet:PetProfile? = nil
    
    private func move(){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.user)
                .addParam(key: .data, value:self.user)
                .addParam(key: .subData, value: self.roomData)
        )
    }
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.chats = []
        self.infinityScrollModel.reload()
    }
        
    private func loadChat(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.dataProvider.requestData(q: .init(id: self.tag, type:
            .getChats(userId:self.userId, page: self.infinityScrollModel.page)
        ))
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? ChatsData else { return }
        if self.user == nil, let userData =  data.receiveUser{
            self.user = User().setData(data: userData)
            self.userName = self.user?.currentProfile.nickName
        }
        if self.pet == nil, let petData =  data.receivePets?.first(where:{$0.isRepresentative == true}){
            self.pet = PetProfile(data: petData)
        }
        self.loadedChatRoom(datas: data.chats ?? [])
    }
    
    private func insertChat(data:ChatData){
        let me = self.dataProvider.user.snsUser?.snsID ?? ""
        let add = ChatItemData().setData(data, me:me, idx:0)
        var isFirst:Bool = self.chats.count == 0
        var currentDataSet = self.chats.last ?? ChatListDataSet()
        let ymd = currentDataSet.originDate?.toDateFormatter(dateFormat: "yyyyMMdd")
        let chatYmd = add.date?.toDateFormatter(dateFormat: "yyyyMMdd")
        let isMe = currentDataSet.isMe
       
        if isFirst {
            isFirst = false
            currentDataSet.date = add.date
            currentDataSet.originDate = add.date
            currentDataSet.index = 0
            currentDataSet.isMe = add.isMe
            currentDataSet.datas.append(add)
            self.chats.append(currentDataSet)
            
        } else if add.isMe != isMe || ymd != chatYmd{
            currentDataSet.index = 1
            currentDataSet = ChatListDataSet()
            currentDataSet.index = 0
            currentDataSet.originDate = add.date
            if ymd != chatYmd {
                currentDataSet.date = add.date
            }
            currentDataSet.isMe = add.isMe
            currentDataSet.datas.append(add)
            self.chats.append(currentDataSet)
        } else {
            currentDataSet.datas.insert(add, at: 0)
            self.chats.removeLast()
            self.chats.append(currentDataSet)
        }
        
        self.infinityScrollModel.uiEvent = .scrollTo(currentDataSet.hashId)

    }
    
    private func loadedChatRoom(datas:[ChatData]){
        let me = self.dataProvider.user.snsUser?.snsID ?? ""
        var added:[ChatItemData] = []
        let start = 0
        let end = datas.count
        added = zip(start...end, datas).map { idx, d in
            return ChatItemData().setData(d,  me:me,  idx: idx)
        }
        
        var index = self.chats.count
        var addedChat:[ChatListDataSet] = []
        var isFirst:Bool = self.chats.count == 0
        var currentDataSet = self.chats.last ?? ChatListDataSet()
        added.forEach{ add in
            let ymd = currentDataSet.originDate?.toDateFormatter(dateFormat: "yyyyMMdd")
            let chatYmd = add.date?.toDateFormatter(dateFormat: "yyyyMMdd")
            let isMe = currentDataSet.isMe
            if isFirst {
                isFirst = false
                currentDataSet.date = add.date
                currentDataSet.originDate = add.date
                currentDataSet.index = 0
                index += 1
                currentDataSet.isMe = add.isMe
                currentDataSet.datas.append(add)
                addedChat.append(currentDataSet)
                
            } else if add.isMe != isMe || ymd != chatYmd{
                currentDataSet = ChatListDataSet()
                currentDataSet.index = index
                index += 1
                currentDataSet.originDate = add.date
                if ymd != chatYmd {
                    currentDataSet.date = add.date
                }
                currentDataSet.isMe = add.isMe
                currentDataSet.datas.append(add)
                addedChat.append(currentDataSet)
            } else {
                currentDataSet.datas.append(add)
            }
        }
        self.chats.insert(contentsOf: addedChat.reversed(), at: 0)
     
        if self.chats.isEmpty {
            withAnimation{
                self.isEmpty = true
            }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
        if self.self.infinityScrollModel.page == 1 , let last = self.chats.last{
            self.infinityScrollModel.uiEvent = .scrollTo(last.hashId, .center)
        }
    }

}


