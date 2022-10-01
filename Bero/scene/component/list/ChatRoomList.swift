//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI


struct ChatRoomList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @Binding var isEdit:Bool
    var marginTop:CGFloat = Dimen.margin.regular

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
                    marginTop: marginTop,
                    marginBottom: Dimen.margin.medium,
                    marginHorizontal: Dimen.app.pageHorinzontal,
                    spacing:Dimen.margin.tiny,
                    isRecycle: true,
                    useTracking: true
                ){
                    ForEach(self.rooms) { data in
                        ChatRoomListItem(data: data, isEdit: self.$isEdit)
                            .onAppear{
                                if data.index == (self.rooms.count-1) {
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
            case .bottom : self.loadChatRoom()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .reload :
                self.resetScroll()
                self.loadChatRoom()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            //if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getChatRooms(let page, let size):
                if size != nil {return}
                if page == 0 {
                    self.resetScroll()
                }
                self.loaded(res)
            case .deleteChatRoom :
                self.resetScroll()
                self.loadChatRoom()
            default : break
            }
        }
        .onAppear(){
            self.loadChatRoom()
        }
    }
    
    @State var isEmpty:Bool = false
    @State var rooms:[ChatRoomListItemData] = []
    
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.rooms = []
        self.infinityScrollModel.reload()
    }
        
    private func loadChatRoom(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .getChatRooms(page: self.infinityScrollModel.page)
        ))
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [ChatRoomData] else { return }
        self.loadedChatRoom(datas: datas)
    }
    
    private func loadedChatRoom(datas:[ChatRoomData]){
        var added:[ChatRoomListItemData] = []
        let start = self.rooms.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return ChatRoomListItemData().setData(d,  idx: idx)
        }
        self.rooms.append(contentsOf: added)
        if self.rooms.isEmpty {
            withAnimation{
                self.isEmpty = true
                self.isEdit = false
            }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }

}


