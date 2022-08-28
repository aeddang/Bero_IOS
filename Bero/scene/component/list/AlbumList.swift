//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI

struct AlbumList: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var user:User? = nil
    var profile:PetProfile? = nil
    var listSize:CGFloat = 300
    var isMine:Bool = false
    var body: some View {
        VStack(spacing:0){
            if self.albumDataSets.isEmpty {
                EmptyItem(type: .myList)
                    .padding(.top, Dimen.margin.regularUltra)
                Spacer().modifier(MatchParent())
            } else {
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
                    ForEach(self.albumDataSets) { dataSet in
                        HStack(spacing: Dimen.margin.regularExtra){
                            ForEach(dataSet.datas) { data in
                                AlbumListItem(data: data, imgSize: self.albumSize)
                            }
                            if !dataSet.isFull {
                                Spacer().frame(width: self.albumSize.width, height: self.albumSize.height)
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
            case .getAlbumPictures(let id, _, _,let size):
                if self.currentId == id && size == nil{
                    self.loaded(res)
                }
            default : break
            }
            
        }
        .onAppear(){
            self.updateAlbum()
        }
    }
    @State var currentId:String = ""
    @State var isEmpty:Bool = true
    
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
        self.resetScroll()
        let w = self.listSize - Dimen.margin.regularExtra
        self.albumSize = CGSize(width: w, height: w * Dimen.item.albumList.height / Dimen.item.albumList.width)
        self.loadAlbum()
        
    }
    func loadAlbum(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        self.currentId = self.dataProvider.user.snsUser?.snsID ?? ""
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .getAlbumPictures(id: self.currentId, .user, page: self.infinityScrollModel.page)))
        
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


