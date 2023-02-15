import Foundation
import SwiftUI

struct AlbumSection: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var user:User
    var pet:PetProfile? = nil
    var listSize:CGFloat = 300
    var pageSize:Int = SystemEnvironment.isTablet ? 12 : 6
    var rowSize:Int = SystemEnvironment.isTablet ? 4 : 2
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: self.title ?? String.pageTitle.album,
                     buttons: self.isEmpty
                     ? self.user.isMe == true ? [.add] : []
                     : [.viewMore]){ type in
                switch type {
                case .viewMore :
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.album)
                            .addParam(key: .data, value: self.user)
                            .addParam(key: .subData, value: self.pet)
                    )
                case .add :
                    self.onPick()
                default : break
                }
            }
            if self.isEmpty {
                EmptyItem(type: .myList)
            } else {
                ForEach(self.albumDataSets) { dataSet in
                    HStack(spacing: Dimen.margin.regularExtra){
                        ForEach(dataSet.datas) { data in
                            AlbumListItem(
                                data: data, user:self.user, pet: self.pet, imgSize: self.albumSize, isEdit: .constant(false)
                            )
                        }
                        if !dataSet.isFull , let count = self.rowSize-dataSet.datas.count {
                            ForEach(0..<count, id: \.self) { _ in
                                Spacer().frame(width: self.albumSize.width, height: self.albumSize.height)
                            }
                        }
                    }
                }
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            switch res.type {
            case .getAlbumPictures(let id, _, let type, _, _, let page, _):
                if self.currentId == id && type == self.currentType && page == 0 {
                    self.reset()
                    self.loaded(res)
                }
            case .registAlbumPicture(_, _, let id, let type, _, _) :
                if self.currentId == id && type == self.currentType {
                    self.reset()
                    self.updateAlbum()
                }
            default : break
            }
        }
        .onAppear(){
            self.updateAlbum()
        }
    }
    @State var title:String? = nil
    @State var currentId:String = ""
    @State var currentType:AlbumApi.Category = .user
    @State var isEmpty:Bool = false
    @State var albums:[AlbumListItemData] = []
    @State var albumDataSets:[AlbumListItemDataSet] = []
    @State var albumSize:CGSize = .zero
    private func updateAlbum(){
        if let name = self.pet?.name {
            self.title = name + String.app.owners + " " + String.pageTitle.album
        }
        let r:CGFloat = CGFloat(self.rowSize)
        let w:CGFloat = (self.listSize - (Dimen.margin.regularExtra * (r-1))) / r
        if let id = self.pet?.petId {
            self.currentId = id.description
            self.currentType = .pet
        } else {
            self.currentId = self.user.snsUser?.snsID ?? ""
            self.currentType = .user
        }
        self.albumSize = CGSize(width: w, height: w * Dimen.item.albumList.height / Dimen.item.albumList.width)
        self.dataProvider.requestData(q: .init(id: self.currentId, type:
                .getAlbumPictures(userId: self.currentId,
                                  self.currentType,
                                  isExpose: self.user.isMe || self.user.isFriend ? nil : true,
                                  page: 0, size: self.pageSize)))
        
    }
    private func reset(){
        self.albums = []
        self.albumDataSets = []
    }
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [PictureData] else { return }
        var added:[AlbumListItemData] = []
        let start = 0
        let end = min(self.pageSize-1, datas.count)
        added = zip(start...end, datas).map { idx, d in
            return AlbumListItemData().setData(d,  idx: idx)
        }
        self.albums.append(contentsOf: added)
        self.setupAlbumDataSet(added: added)
        if self.albums.isEmpty {
            withAnimation{ self.isEmpty = true }
        } else {
            withAnimation{ self.isEmpty = false }
        }
    }
    
    private func setupAlbumDataSet(added:[AlbumListItemData]){
        let count:Int = self.rowSize
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

    
    private func onPick(){
        self.appSceneObserver.select = .imgPicker(self.tag){ pick in
            guard let pick = pick else {return}
            DispatchQueue.global(qos:.background).async {
                let hei = AlbumApi.originSize * CGFloat(pick.cgImage?.height ?? 1) / CGFloat(pick.cgImage?.width ?? 1)
                let size = CGSize(
                    width: AlbumApi.originSize,
                    height: hei)
                let image = pick.normalized().crop(to: size).resize(to: size)
                let sizeList = CGSize(
                    width: AlbumApi.thumbSize,
                    height: AlbumApi.thumbSize)
                let thumbImage = pick.normalized().crop(to: sizeList).resize(to: sizeList)
                DispatchQueue.main.async {
                    self.pagePresenter.isLoading = false
                    self.updateConfirm(img:image, thumbImage:thumbImage)
                }
            }
        }
    }
    
    private func updateConfirm(img:UIImage, thumbImage:UIImage){
        var isExpose = self.repository.storage.isExpose
        if self.repository.storage.isExposeSetup {
            self.update(img: img, thumbImage: thumbImage, isExpose:isExpose)
        } else {
            self.appSceneObserver.alert = .confirm(nil, String.alert.exposeConfirm){ isOk in
                isExpose = isOk
                self.update(img: img, thumbImage: thumbImage, isExpose:isExpose)
            }
        }
    }
    
    private func update(img:UIImage, thumbImage:UIImage, isExpose:Bool){
        self.dataProvider.requestData(q: .init(
            id: self.currentId,
            type: .registAlbumPicture(img: img, thumbImg: thumbImage, userId: self.currentId, self.currentType, isExpose:isExpose)
        ))
    }
}


