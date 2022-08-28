import Foundation
import SwiftUI

struct MyFriendSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider

    var listSize:CGFloat = 300
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.friends, buttons: self.isEmpty ? [] : [.viewMore]){ type in
                switch type {
                case .viewMore : self.moveFriend()
                default : break
                }
            }
            if self.isEmpty {
                EmptyItem(type: .myList)
            } else {
                ForEach(self.friendDataSets) { dataSet in
                    HStack(spacing: Dimen.margin.medium){
                        ForEach(dataSet.datas) { data in
                            FriendListItem(
                                data: data,
                                imgSize: self.imageSize,
                                action: {self.moveFriend(id:data.contentID)}
                            )
                        }
                        if !dataSet.isFull {
                            Spacer().frame(width: self.imageSize, height: self.imageSize)
                        }
                    }
                }
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getMission: self.loaded(res)
            default : break
            }
        }
        .onAppear(){
            self.updateFriend()
        }
    }
    
    @State var isEmpty:Bool = false
    @State var friends:[FriendListItemData] = []
    @State var friendDataSets:[FriendListItemDataSet] = []
    @State var imageSize:CGFloat = 0
    private func updateFriend(){
        self.imageSize = (self.listSize - (Dimen.margin.medium*2)) / 3
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                 .getMission(userId: self.dataProvider.user.snsUser?.snsID ?? "",
                             petId: nil, .all,
                             page: 1, size: 3)))
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [MissionData] else { return }
        var added:[FriendListItemData] = []
        let start = self.friends.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return FriendListItemData().setData(d,  idx: idx)
        }
        self.friends.append(contentsOf: added)
        self.setupFriendDataSet(added: added)
        if self.friends.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
    }
                          
    
    private func setupFriendDataSet(added:[FriendListItemData]){
        let count:Int = 3
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
        
    }
}


