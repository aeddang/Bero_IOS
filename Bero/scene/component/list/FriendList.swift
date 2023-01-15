//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import SwiftUI
extension FriendList {
    static let row:Int = SystemEnvironment.isTablet ? 6 : 3
    enum  ListType{
        case friend, request, requested
        var title:String {
            switch self {
            case .friend : return String.pageTitle.friends
            case .request, .requested : return String.pageTitle.friendRequest
            }
        }
        var text:String{
            switch self {
            case .friend : return "My Friends"
            case .request : return "Request Friends"
            case .requested : return "Received Friends Request"
            }
        }
        
        var action:String{
            switch self {
            case .friend : return "Friend"
            case .request : return "Request"
            case .requested : return "Get Request"
            }
        }
        
        var status:FriendStatus{
            switch self {
            case .friend : return .friend
            case .request : return .requestFriend
            case .requested : return .recieveFriend
            }
        }
    }
}

struct FriendList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var type:ListType = .friend
    var user:User? = nil
    var listSize:CGFloat = 300
    var marginBottom:CGFloat = Dimen.margin.medium
    var isHorizontal:Bool = false
    var body: some View {
        VStack(spacing:0){
            if self.isEmpty {
                EmptyItem(type: .myList)
                    .padding(.top, self.isHorizontal ? 0 : Dimen.margin.regularUltra)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                Spacer().modifier(MatchParent())
            } else {
                if self.isHorizontal {
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .horizontal,
                        showIndicators : false,
                        marginTop: 0,
                        marginBottom: 0,
                        marginHorizontal: Dimen.app.pageHorinzontal,
                        spacing:Dimen.margin.regularUltra,
                        isRecycle: true,
                        useTracking: true
                    ){
                        ForEach(self.friends) { data in
                            FriendListItem(
                                data: data,
                                imgSize: self.imageSize,
                                isMe: self.isMe,
                                status: self.type.status == .friend ? .chat : self.type.status,
                                isHorizontal: true
                            ){
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.user)
                                        .addParam(key: .id, value:data.userId)
                                )
                            }
                            .onAppear{
                                if  data.index == (self.friends.count-1) {
                                    self.infinityScrollModel.event = .bottom
                                }
                            }
                        }
                            
                    }
                } else {
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .vertical,
                        showIndicators : true,
                        marginTop: Dimen.margin.regularUltra,
                        marginBottom: self.marginBottom,
                        marginHorizontal: Dimen.app.pageHorinzontal,
                        spacing:Dimen.margin.regularUltra,
                        isRecycle: true,
                        useTracking: true
                    ){
                        ForEach(self.friends) { data in
                            FriendListItem(
                                data: data,
                                imgSize: Dimen.profile.mediumUltra,
                                isMe: self.isMe,
                                status: self.type.status,
                                isHorizontal: false
                            ){
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.user)
                                        .addParam(key: .id, value:data.userId)
                                )
                            }
                            .onAppear{
                                if  data.index == (self.friends.count-1) {
                                    self.infinityScrollModel.event = .bottom
                                }
                            }
                        }
                    }
                }
                
            }
        }
        .onReceive(self.infinityScrollModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .bottom : self.loadFriend()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .reload : self.updateFriend()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if res.id != self.currentId {return}
            switch res.type {
            case .getFriend(_, let page ,_), .getRequestFriend(let page ,_), .getRequestedFriend(let page ,_):
                if page == 0 {
                    self.resetScroll()
                }
                self.loaded(res)
                self.pageObservable.isInit = true
                
            default : break
            }
        }
        .onReceive(self.dataProvider.$error){err in
            guard let err = err else { return }
            if err.id != self.currentId {return}
            switch err.type {
            case .getFriend, .getRequestFriend, .getRequestedFriend :
                self.pageObservable.isInit = true
                
            default : break
            }
        }
        .onAppear(){
            self.isMe = self.dataProvider.user.isSameUser(user)
            self.updateFriend()
            
        }
    }
    @State var currentId:String = ""
    @State var isEmpty:Bool = false
    @State var friends:[FriendListItemData] = []
    @State var imageSize:CGFloat = 0
    @State var isMe:Bool = false
    
    private func updateFriend(){
        self.currentId = self.user?.snsUser?.snsID ?? ""
        self.resetScroll()
        let r:CGFloat = CGFloat(Self.row)
        let w:CGFloat = ( self.listSize - (Dimen.margin.regularExtra * (r-1)) - (Dimen.app.pageHorinzontal*2) ) / r
        self.imageSize = w
        self.loadFriend()
    }
    
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.friends = []
        self.infinityScrollModel.reload()
    }
    
    private func loadFriend(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.currentId = self.user?.snsUser?.snsID ?? ""
        switch self.type {
        case .friend :
            self.dataProvider.requestData(q: .init(id: self.currentId, type:.getFriend(userId: self.currentId, page: self.infinityScrollModel.page)))
        case .requested :
            self.dataProvider.requestData(q: .init(id: self.currentId, type:.getRequestedFriend(page: self.infinityScrollModel.page)))
        case .request :
            self.dataProvider.requestData(q: .init(id: self.currentId, type:.getRequestFriend(page: self.infinityScrollModel.page)))
        }
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [FriendData] else { return }
        self.loadedFriend(datas: datas)
    }
    
    private func loadedFriend(datas:[FriendData]){
        var added:[FriendListItemData] = []
        let start = self.friends.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return FriendListItemData().setData(d,  idx: idx, type:self.type.status)
        }
        self.friends.append(contentsOf: added)
        if self.friends.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    /*
     //@State var friendDataSets:[FriendListItemDataSet] = []
    private func setupFriendDataSet(added:[FriendListItemData]){
    
        let count:Int = Self.row
        var rows:[FriendListItemDataSet] = []
        var cells:[FriendListItemData] = []
        var total = self.friendDataSets.count
        added.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    FriendListItemDataSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                FriendListItemDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.friendDataSets.append(contentsOf: rows)
    }
     */
}


