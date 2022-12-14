import Foundation
import SwiftUI

struct FriendSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var user:User
    var listSize:CGFloat = 300
    var type:FriendList.ListType = .friend
    var pageSize:Int = SystemEnvironment.isTablet ? 5 : 3
    var rowSize:Int = SystemEnvironment.isTablet ? 5 : 3
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: self.type.title, buttons:[.viewMore]){ type in
                switch type {
                case .viewMore :
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.friend)
                            .addParam(key: .data, value: self.user)
                            .addParam(key: .type, value: self.type)
                    )
                default : break
                }
            }
            if self.isEmpty {
                EmptyItem(type: .myList)
            } else {
                ForEach(self.friendDataSets) { dataSet in
                    HStack(spacing: Dimen.margin.regularExtra){
                        ForEach(dataSet.datas) { data in
                            FriendListItem(
                                data: data,
                                imgSize: self.imageSize,
                                isMe: self.isMe,
                                action: {self.moveFriend(id:data.userId)}
                            )
                        }
                        if !dataSet.isFull , let count = self.rowSize-dataSet.datas.count {
                            ForEach(0..<count, id: \.self) { _ in
                                Spacer().frame(width: self.imageSize, height: self.imageSize)
                            }
                        }
                    }
                }
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if res.id != self.currentId {return}
            switch res.type {
            case .getFriend(_, let page ,_):
                if page == 0 && self.type == .friend{
                    self.reset()
                    self.loaded(res)
                }
            case .getRequestFriend(let page ,_):
                if page == 0 && self.type == .request{
                    self.reset()
                    self.loaded(res)
                }
            case .getRequestedFriend(let page ,_):
                if page == 0 && self.type == .requested{
                    self.reset()
                    self.loaded(res)
                }
            default : break
            }
        }
        
        .onAppear(){
            self.updateFriend()
            self.isMe = self.dataProvider.user.isSameUser(user)
        }
    }
    @State var currentId:String = ""
    @State var isMe:Bool = false
    @State var isEmpty:Bool = false
    @State var friends:[FriendListItemData] = []
    @State var friendDataSets:[FriendListItemDataSet] = []
    @State var imageSize:CGFloat = 0
    private func updateFriend(){
        self.currentId = self.user.snsUser?.snsID ?? ""
        let r:CGFloat = CGFloat(self.rowSize)
        let w:CGFloat = (self.listSize - (Dimen.margin.regularExtra * (r-1))) / r
        self.imageSize = w
        switch self.type {
        case .friend :
            self.dataProvider.requestData(q: .init(id: self.currentId, type:.getFriend(userId: self.currentId, page: 0, size: self.pageSize)))
        case .requested :
            self.dataProvider.requestData(q: .init(id: self.currentId, type:.getRequestedFriend(page: 0, size: self.pageSize)))
        case .request :
            self.dataProvider.requestData(q: .init(id: self.currentId, type:.getRequestFriend(page: 0, size: self.pageSize)))
        }
    }
    private func reset(){
        self.friends = []
        self.friendDataSets = []
    }
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [FriendData] else { return }
        
        var added:[FriendListItemData] = []
        let start = self.friends.count
        let end = min(self.pageSize, datas.count)
        added = zip(start...end, datas).map { idx, d in
            return FriendListItemData().setData(d,  idx: idx, type: self.type.status)
        }
        self.friends.append(contentsOf: added)
        self.setupFriendDataSet(added: added)
        if self.friends.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
    }
                          
    private func setupFriendDataSet(added:[FriendListItemData]){
        let count:Int = self.rowSize
        var rows:[FriendListItemDataSet] = []
        var cells:[FriendListItemData] = []
        var total = added.count
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
    
    private func moveFriend(id:String? = nil){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.user)
                .addParam(key: .id, value:id)
        )
    }
}


