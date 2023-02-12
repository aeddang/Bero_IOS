//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI


struct RewardHistoryList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var type:HistoryItem.HistoryType = .exp
    var user:User? = nil
    
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
                    marginVertical: Dimen.margin.medium,
                    marginHorizontal: Dimen.app.pageHorinzontal,
                    spacing:Dimen.margin.regularUltra,
                    isRecycle: true,
                    useTracking: true
                ){
                    ForEach(self.historys) { data in
                        RewardHistoryListItem(data: data)
                            .onAppear{
                                if data.index == (self.historys.count-1) {
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
            case .bottom : self.loadHistory()
            default : break
            }
        }
        
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getRewardHistory(let userId, _, _, _):
                if self.currentId == userId {
                    self.loaded(res)
                }
            default : break
            }
            
        }
        .onAppear(){
            self.loadHistory()
        }
    }
    @State var currentId:String = ""
    @State var isEmpty:Bool = false
    @State var historys:[RewardHistoryListItemData] = []
    
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.historys = []
        self.infinityScrollModel.reload()
    }
        
    func loadHistory(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.currentId = self.user?.snsUser?.snsID ?? ""
        self.dataProvider.requestData(q: .init(id: self.tag, type:
            .getRewardHistory(userId: self.currentId, type:self.type.apiType, page: self.infinityScrollModel.page)
        ))
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [RewardHistoryData] else { return }
        self.loadedHistory(datas: datas)
    }
    
    private func loadedHistory(datas:[RewardHistoryData]){
        var added:[RewardHistoryListItemData] = []
        let start = self.historys.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return RewardHistoryListItemData().setData(d, type: self.type, idx: idx)
        }
        self.historys.append(contentsOf: added)
        if self.historys.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    
}


