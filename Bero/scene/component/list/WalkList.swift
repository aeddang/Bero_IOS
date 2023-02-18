import Foundation
import SwiftUI

struct WalkList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    let userId:String
    var isFriend:Bool = false
    var listSize:CGFloat = 300
    var marginBottom:CGFloat = Dimen.margin.medium
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
                    showIndicators : true,
                    marginTop: Dimen.margin.regularUltra,
                    marginBottom: self.marginBottom,
                    marginHorizontal: Dimen.app.pageHorinzontal,
                    spacing:Dimen.margin.regularUltra,
                    isRecycle: true,
                    useTracking: true
                ){
                    ForEach(self.walks) { data in
                        WalkListItem(
                            data: data, imgSize: self.walkListSize)
                        {
                            self.move(data: data)
                        }
                        .onAppear{
                            if  data.index == (self.walks.count-1) {
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
            case .bottom : self.loadWalk()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            //case .reload : self.updateFriend()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if res.id != self.userId {return}
            switch res.type {
            case .getUserWalks(_, let page, _) :
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
            if err.id != self.userId {return}
            switch err.type {
            case .getUserWalks :
                self.pageObservable.isInit = true
                
            default : break
            }
        }
        .onAppear(){
            self.updateWalk()
            
        }
    }
    
    @State var isEmpty:Bool = false
    @State var walkListSize:CGSize = .zero
    @State var walks:[WalkListItemData] = []
    private func updateWalk(){
        let w = self.listSize - (Dimen.app.pageHorinzontal*2)
        self.walkListSize = CGSize(width: w, height: w * Dimen.item.walkList.height / Dimen.item.walkList.width)
        self.resetScroll()
        self.loadWalk()
    }
    
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.walks = []
        self.infinityScrollModel.reload()
    }
    
    private func loadWalk(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.dataProvider.requestData(q: .init(id:self.userId, type: .getUserWalks(userId: self.userId, page: self.infinityScrollModel.page) ))
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [WalkData] else { return }
        self.loadedWalk(datas: datas)
    }
    
    private func loadedWalk(datas:[WalkData]){
        var added:[WalkListItemData] = []
        let start = self.walks.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return WalkListItemData().setData(d,  idx: idx)
        }
        self.walks.append(contentsOf: added)
        if self.walks.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    private func move(data:WalkListItemData){
        guard let walkData = data.originData else {return}
        let mission = Mission().setData(walkData, userId: self.userId)
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.walkInfo)
                .addParam(key: .data, value: mission)
        
        )
    }
}

