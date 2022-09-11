//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI


struct MessageList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @Binding var isEdit:Bool
    @State var isCheckAll:Bool = false
    var body: some View {
        VStack(spacing:0){
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
                    marginVertical: Dimen.margin.medium,
                    marginHorizontal: Dimen.app.pageHorinzontal,
                    spacing:Dimen.margin.tiny,
                    isRecycle: true,
                    useTracking: true
                ){
                    ForEach(self.messages) { data in
                        MessageListItem(data: data, isEdit: self.$isEdit)
                            .onAppear{
                                if data.index == (self.messages.count-1) {
                                    self.infinityScrollModel.event = .bottom
                                }
                            }
                    }
                }
            }
            if self.isEdit {
                HStack(spacing:Dimen.margin.micro){
                    FillButton(
                        type: .fill,
                        text: String.button.checkAll,
                        color: Color.app.black,
                        isActive: self.isCheckAll
                    ){_ in
                        withAnimation{
                            self.isCheckAll.toggle()
                        }
                        self.messages.forEach{$0.isDelete = self.isCheckAll}
                    }
                    FillButton(
                        type: .fill,
                        text: String.button.delete,
                        color: Color.brand.primary,
                        isActive: true
                    ){_ in
                        self.deleteMessage()
                    }
                }
                .padding(.bottom, Dimen.app.bottom + Dimen.margin.thin)
                .padding(.horizontal, Dimen.app.pageHorinzontal)
            }
        }
        .onReceive(self.infinityScrollModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .bottom : self.loadMessage()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .reload :
                self.resetScroll()
                self.loadMessage()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getChats:
                self.loaded(res)
            case .deleteChat, .deleteAllChat :
                self.resetScroll()
                self.loadMessage()
            default : break
            }
            
        }
        .onAppear(){
            self.loadMessage()
        }
    }
    
    @State var isEmpty:Bool = false
    @State var messages:[MessageListItemData] = []
    
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.messages = []
        self.infinityScrollModel.reload()
    }
        
    private func loadMessage(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .getChats(page: self.infinityScrollModel.page)
        ))
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [ChatData] else { return }
        self.loadedMessage(datas: datas)
    }
    
    private func loadedMessage(datas:[ChatData]){
        var added:[MessageListItemData] = []
        let start = self.messages.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return MessageListItemData().setData(d,  idx: idx)
        }
        self.messages.append(contentsOf: added)
        if self.messages.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    
    private func deleteMessage(){
        let selets = self.messages.filter{$0.isDelete}
        if selets.isEmpty {
            self.appSceneObserver.event = .toast(String.alert.noItemsSelected)
            return
        }
        let del = selets.reduce("", {$0 + "," + $1.chatId.description}).dropFirst()
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .deleteAllChat(chatIds: String(del))
        ))
        
    }
}


