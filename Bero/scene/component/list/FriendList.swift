//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI
extension FriendList {
    static let row:Int = SystemEnvironment.isTablet ? 5 : 2
    enum  ListType{
        case friend, request, requested
        var text:String{
            switch self {
            case .friend : return "Friend"
            case .request : return "Request"
            case .requested : return "Get Request"
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
    var body: some View {
        VStack(spacing:0){
            if self.isEmpty {
                EmptyItem(type: .myList)
                    .padding(.top, Dimen.margin.regularUltra)
                Spacer().modifier(MatchParent())
            } else {
                InfinityScrollView(
                    viewModel: self.infinityScrollModel,
                    axes: .vertical,
                    showIndicators : false,
                    marginTop: Dimen.margin.regularUltra,
                    marginBottom: self.marginBottom,
                    marginHorizontal: Dimen.app.pageHorinzontal,
                    spacing:Dimen.margin.regularUltra,
                    isRecycle: true,
                    useTracking: true
                ){
                    ForEach(self.friendDataSets) { dataSet in
                        HStack(spacing: Dimen.margin.regularExtra){
                            ForEach(dataSet.datas) { data in
                                FriendListItem(
                                    data: data,
                                    imgSize: self.imageSize,
                                    status: self.type.status
                                ){
                                    self.pagePresenter.openPopup(
                                        PageProvider.getPageObject(.user)
                                            .addParam(key: .id, value:data.userId)
                                    )
                                }
                            }
                            if !dataSet.isFull , let count = Self.row-dataSet.datas.count {
                                ForEach(0..<count, id: \.self) { _ in
                                    Spacer().frame(width: self.imageSize, height: self.imageSize)
                                }
                            }
                        }
                        .onAppear{
                            if  dataSet.index == (self.friendDataSets.count-1) {
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
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getFriend(let page ,_), .getRequestFriend(let page ,_), .getRequestedFriend(let page ,_):
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
            if !err.id.hasPrefix(self.tag) {return}
            switch err.type {
            case .getFriend, .getRequestFriend, .getRequestedFriend :
                self.pageObservable.isInit = true
                
            default : break
            }
        }
        .onAppear(){
            self.updateFriend()
        }
    }
    @State var currentId:String = ""
    @State var isEmpty:Bool = false
    @State var friends:[FriendListItemData] = []
    @State var friendDataSets:[FriendListItemDataSet] = []
    @State var imageSize:CGFloat = 0
    
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
        self.friendDataSets = []
        self.infinityScrollModel.reload()
    }
    
    private func loadFriend(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.currentId = self.user?.snsUser?.snsID ?? ""
        
        switch self.type {
        case .friend :
            self.dataProvider.requestData(q: .init(id: self.tag, type:.getFriend(page: self.infinityScrollModel.page)))
        case .requested :
            self.dataProvider.requestData(q: .init(id: self.tag, type:.getRequestedFriend(page: self.infinityScrollModel.page)))
        case .request :
            self.dataProvider.requestData(q: .init(id: self.tag, type:.getRequestFriend(page: self.infinityScrollModel.page)))
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
        self.setupFriendDataSet(added: added)
        if self.friends.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    
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
}


