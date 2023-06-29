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
    static let row:Int = SystemEnvironment.isTablet ? 4 : 2
    enum  ListType{
        case detail, normal
        
        var row:Int{
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
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var type:ListType = .normal
    var user:User? = nil
    var pet:PetProfile? = nil
    var initId:Int? = nil
    var listSize:CGFloat = 300
    var marginBottom:CGFloat = Dimen.margin.medium
    @Binding var isEdit:Bool
    @State var isCheckAll:Bool = false
   
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
                    marginTop: Dimen.margin.regularUltra,
                    marginBottom: self.marginBottom,
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
                                    AlbumListItem(data: data, user: self.user, imgSize: self.albumSize, isEdit: self.$isEdit)
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
                            AlbumListDetailItem(data: data, user: self.user, imgSize: self.albumSize, isEdit: self.$isEdit)
                            .id(data.hashId)
                            .onAppear{
                                if data.index == (self.albums.count-1) {
                                    self.infinityScrollModel.event = .bottom
                                }
                            }
                            .onTapGesture {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.pictureViewer)
                                        .addParam(key: .data, value: data)
                                        .addParam(key: .userData, value: self.user)
                                )
                            }
                        }
                    }
                    
                }
            }
            if self.isEdit {
                HStack(spacing:Dimen.margin.micro){
                    FillButton(
                        type: .fill,
                        text: String.button.checkAll,
                        color: Color.app.black,
                        isActive: self.isCheckAll
                    ){_ in
                        withAnimation{
                            self.isCheckAll.toggle()
                        }
                        self.albums.forEach{$0.isDelete = self.isCheckAll}
                    }
                    FillButton(
                        type: .fill,
                        text: String.button.delete,
                        color: Color.brand.primary,
                        isActive: true
                    ){_ in
                        self.deleteAlbum()
                    }
                }
                .padding(.vertical, Dimen.margin.thin)
                .padding(.horizontal, Dimen.app.pageHorinzontal)
            }
        }
        .onReceive(self.infinityScrollModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .bottom : self.loadAlbum()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .reload : self.updateAlbum()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if self.currentId != res.id { return }
            switch res.type {
            case .getAlbumPictures(_, _, let type , _, _, let page ,let size):
                if type == self.currentType && size == nil{
                    if page == 0 {
                        self.resetScroll()
                    }
                    self.loaded(res)
                    self.pageObservable.isInit = true
                }
            case .registAlbumPicture(_, _, _, let type, _, _) :
                if type == self.currentType {
                    self.resetScroll()
                    self.loadAlbum()
                }
            case .deleteAlbumPictures :
                self.resetScroll()
                self.loadAlbum()
                
            default : break
            }
        }
        .onReceive(self.dataProvider.$error){err in
            guard let err = err else { return }
            if self.currentId != err.id { return }
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
    @State var currentType:AlbumApi.Category = .user
    @State var isEmpty:Bool = false
    @State var albums:[AlbumListItemData] = []
    @State var albumDataSets:[AlbumListItemDataSet] = []
    @State var albumSize:CGSize = .zero
    private func updateAlbum(){
        
        self.resetScroll()
        let w = (self.listSize
                 - (Dimen.margin.regularExtra * CGFloat(self.type.row-1))
                 - (self.type.marginHorizontal*2)) / CGFloat(self.type.row)
        self.albumSize = CGSize(width: w, height: w * Dimen.item.albumList.height / Dimen.item.albumList.width)
        self.loadAlbum()
        
    }
    
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.isCheckAll = false
        self.albums = []
        self.albumDataSets = []
        self.infinityScrollModel.reload()
    }
    
    private func loadAlbum(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        if let id = self.pet?.petId {
            self.currentId = id.description
            self.currentType = .pet
        } else {
            self.currentId = self.user?.snsUser?.snsID ?? ""
            self.currentType = .user
        }
       
        self.dataProvider.requestData(q: .init(id: self.currentId, type:
                .getAlbumPictures(userId: self.currentId, self.currentType,
                                  isExpose: self.user?.isMe == true || self.user?.isFriend == true  ? nil : true,
                                  page: self.infinityScrollModel.page)))
        
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
            return AlbumListItemData().setData(d,  idx: idx)
        }
        self.albums.append(contentsOf: added)
        self.setupAlbumDataSet(added: added)
        if self.albums.isEmpty {
            withAnimation{
                self.isEmpty = true
                self.isEdit = false
            }
        } else {
            withAnimation{
                self.isEmpty = false
            }
        }
        if self.infinityScrollModel.page == 0 , let initId = self.initId, let find = added.first(where: {$0.pictureId == initId}) {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.infinityScrollModel.uiEvent = .scrollMove(find.hashId)
            }
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
    
    private func deleteAlbum(){
        let selects = self.albums.filter{$0.isDelete}
        if selects.isEmpty {
            self.appSceneObserver.event = .toast(String.alert.noItemsSelected)
            return
        }
        let del = selects.reduce("", {$0 + "," + $1.pictureId.description}).dropFirst()
        self.dataProvider.requestData(q: .init(id: self.currentId, type:
                .deleteAlbumPictures(ids: String(del))
        ))
        
    }
}


