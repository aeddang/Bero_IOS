import Foundation
import SwiftUI

struct MyHistorySection: PageComponent{
    enum HistoryType{
        case mission, album
    }
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var calenderModel: CalenderModel = CalenderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var listSize:CGFloat = 300
    var body: some View {
        VStack(spacing:0){
            TitleTab(type:.section, title: String.pageText.myHistory){_ in }
            MenuTab(
                viewModel:self.navigationModel,
                buttons: [String.button.calendar, String.button.album],
                selectedIdx: self.navigationModel.index
            )
            .padding(.top, Dimen.margin.tiny)
            
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                axes: .vertical,
                showIndicators : false,
                marginTop: Dimen.margin.regularUltra,
                marginHorizontal: 0,
                spacing:Dimen.margin.regularUltra,
                isRecycle: true,
                useTracking: true
            ){
                switch self.historyType {
                case .mission :
                    CPCalendar(
                        viewModel: self.calenderModel
                    )
                    ForEach(self.missions) { data in
                        WalkListItem(data: data, imgSize: self.missionSize){
                            
                        }
                    }
                case .album :
                    ForEach(self.albumDataSets) { dataSet in
                        HStack(spacing: Dimen.margin.regularExtra){
                            ForEach(dataSet.datas) { data in
                                AlbumListItem(data: data, imgSize: self.albumSize){
                                    
                                }
                            }
                            if !dataSet.isFull {
                                Spacer().frame(width: self.albumSize.width, height: self.albumSize.height)
                            }
                        }
                    }
                }
                if self.isEmpty {
                    VStack(spacing: Dimen.margin.regularExtra){
                        EmptyItem(type: .myList)
                        FillButton(
                            type: .fill,
                            text: String.button.startWalking,
                            color:Color.app.white,
                            gradient: Color.app.orangeGradient
                        ){_ in
                            
                        }
                        .modifier(Shadow())
                    }
                }
            }
        }
        .onReceive(self.navigationModel.$index){ idx in
            if idx == 0 {
                self.historyType = .mission
                self.updateMission()
            } else {
                self.historyType = .album
                self.updateAlbum()
            }
        }
        .onReceive(self.infinityScrollModel.$event){ evt in
            if self.historyType != .mission {return}
            guard let evt = evt else {return}
            switch evt {
            case .bottom : self.loadAlbum()
            default : break
            }
        }
        .onReceive(self.calenderModel.$event){ evt in
            if self.historyType != .mission {return}
            guard let evt = evt else {return}
            switch evt {
            case .selectdDate :
                self.updateMission()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .searchMission: self.loaded(res)
            case .getMission: self.loaded(res)
            default : break
            }
            
        }
        .onAppear(){
            
        }
    }
    @State var historyType:MyHistorySection.HistoryType = .mission
    @State var isEmpty:Bool = true
    @State var date:Date = AppUtil.networkTimeDate()
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [MissionData] else { return }
        switch self.historyType {
        case .mission : self.loadedMission(datas: datas)
        case .album : self.loadedAlbum(datas: datas)
        }
    }
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.missions = []
        self.albums = []
        self.albumDataSets = []
        self.infinityScrollModel.reload()
    }
    
    
    @State var missions:[WalkListItemData] = []
    @State var missionSize:CGSize = .zero
    private func updateMission(){
        self.resetScroll()
        self.infinityScrollModel.onLoad()
        self.missionSize = CGSize(width: self.listSize, height: self.listSize * Dimen.item.walkList.height / Dimen.item.walkList.width)
        self.dataProvider.requestData(q: .init(id: self.tag, type: .searchMission(.all, .Time, size: 999)))
    }
    private func loadedMission(datas:[MissionData]){
        var added:[WalkListItemData] = []
        let start = self.missions.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return WalkListItemData().setData(d,  idx: idx, isMine: true)
        }
        self.missions.append(contentsOf: added)
        self.missions.append(WalkListItemData())
        self.missions.append(WalkListItemData())
        self.missions.append(WalkListItemData())
        if self.missions.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    
    
    @State var albums:[AlbumListItemData] = []
    @State var albumDataSets:[AlbumListItemDataSet] = []
    @State var albumSize:CGSize = .zero
    private func updateAlbum(){
        self.resetScroll()
        let w = self.listSize - Dimen.margin.regularExtra
        self.albumSize = CGSize(width: w, height: w * Dimen.item.albumList.height / Dimen.item.albumList.width)
        self.loadAlbum()
        
    }
    func loadAlbum(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .getMission(userId: self.dataProvider.user.snsUser?.snsID ?? "",
                            petId: nil, .all,
                            page: self.infinityScrollModel.page)))
        
    }
    private func loadedAlbum(datas:[MissionData]){
        var added:[AlbumListItemData] = []
        let start = self.albums.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return AlbumListItemData().setData(d,  idx: idx, isMine: true)
        }
        self.albums.append(contentsOf: added)
        self.setupAlbumDataSet(added: added)
        if self.albums.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    
    private func setupAlbumDataSet(added:[AlbumListItemData]){
        let count:Int = 2
        var rows:[AlbumListItemDataSet] = []
        var cells:[AlbumListItemData] = []
        var total = added.count
        added.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    AlbumListItemDataSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                AlbumListItemDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.albumDataSets.append(contentsOf: rows)
    }
}


