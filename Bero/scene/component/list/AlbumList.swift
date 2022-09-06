//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI
extension AlbumList {
    static let row:Int = 2
    enum  ListType{
        case detail, normal
        
        var raw:Int{
            switch self {
            case .detail : return 1
            default : return AlbumList.row
            }
        }
        
        var marginHorizontal:CGFloat{
            switch self {
            case .detail : return 0
            default : return Dimen.app.pageHorinzontal
            }
        }
    }
}

struct AlbumList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var type:ListType = .normal
    var user:User? = nil
    var profile:PetProfile? = nil
    var listSize:CGFloat = 300
    var isMine:Bool = false
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
                    marginHorizontal: self.type.marginHorizontal,
                    spacing:Dimen.margin.regularUltra,
                    isRecycle: true,
                    useTracking: true
                ){
                    switch self.type {
                    case .normal:
                        ForEach(self.albumDataSets) { dataSet in
                            HStack(spacing: Dimen.margin.regularExtra){
                                ForEach(dataSet.datas) { data in
                                    AlbumListItem(data: data, user: self.user, imgSize: self.albumSize)
                                }
                                if !dataSet.isFull {
                                    Spacer().frame(width: self.albumSize.width, height: self.albumSize.height)
                                }
                            }
                            .onAppear{
                                if  dataSet.index == (self.albumDataSets.count-1) {
                                    self.infinityScrollModel.event = .bottom
                                }
                            }
                        }
                    case .detail :
                        ForEach(self.albums) { data in
                            AlbumListDetailItem(data: data, imgSize: self.albumSize)
                            .onAppear{
                                if data.index == (self.albums.count-1) {
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
            case .bottom : self.loadAlbum()
            default : break
            }
        }
        
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getAlbumPictures(let id, _, let page ,let size):
                if self.currentId == id && size == nil{
                    if page == 0 {
                        self.resetScroll()
                    }
                    self.loaded(res)
                    self.pageObservable.isInit = true
                }
            default : break
            }
        }
        .onReceive(self.dataProvider.$error){err in
            guard let err = err else { return }
            if !err.id.hasPrefix(self.tag) {return}
            switch err.type {
            case .getAlbumPictures :
                self.pageObservable.isInit = true
                
            default : break
            }
        }
        .onAppear(){
            self.updateAlbum()
        }
    }
    @State var currentId:String = ""
    @State var isEmpty:Bool = false
    
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.albums = []
        self.albumDataSets = []
        self.infinityScrollModel.reload()
    }
        
    @State var albums:[AlbumListItemData] = []
    @State var albumDataSets:[AlbumListItemDataSet] = []
    @State var albumSize:CGSize = .zero
    private func updateAlbum(){
        self.currentId = self.user?.snsUser?.snsID ?? ""
        self.resetScroll()
        let w = (self.listSize
                 - (Dimen.margin.regularExtra * CGFloat(self.type.raw-1))
                 - (self.type.marginHorizontal*2)) / CGFloat(self.type.raw)
        self.albumSize = CGSize(width: w, height: w * Dimen.item.albumList.height / Dimen.item.albumList.width)
        self.loadAlbum()
        
    }
    func loadAlbum(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.currentId = self.user?.snsUser?.snsID ?? ""
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .getAlbumPictures(id: self.currentId, .mission, page: self.infinityScrollModel.page)))
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [PictureData] else { return }
        self.loadedAlbum(datas: datas)
    }
    
    private func loadedAlbum(datas:[PictureData]){
        var added:[AlbumListItemData] = []
        let start = self.albums.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return AlbumListItemData().setData(d,  idx: idx, isMine: self.isMine)
        }
        self.albums.append(contentsOf: added)
        self.setupAlbumDataSet(added: added)
        if self.albums.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    
    private func setupAlbumDataSet(added:[AlbumListItemData]){
        if self.type == .detail {return}
        let count:Int = Self.row
        var rows:[AlbumListItemDataSet] = []
        var cells:[AlbumListItemData] = []
        var total = self.albumDataSets.count
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


