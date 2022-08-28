import Foundation
import SwiftUI

struct MyAlbumSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var user:User? = nil
    var profile:PetProfile? = nil
    var listSize:CGFloat = 300
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.album, buttons: self.isEmpty ? [] : [.viewMore]){ type in
                switch type {
                case .viewMore : self.moveAlbum()
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
                                data: data, imgSize: self.albumSize
                            )
                        }
                        if !dataSet.isFull {
                            Spacer().frame(width: self.albumSize.width, height: self.albumSize.height)
                        }
                    }
                }
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getAlbumPictures(let id, _, _, _):
                if self.currentId == id {
                    self.reset()
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
    @State var isEmpty:Bool = false
    @State var albums:[AlbumListItemData] = []
    @State var albumDataSets:[AlbumListItemDataSet] = []
    @State var albumSize:CGSize = .zero
    private func updateAlbum(){
        let w = (self.listSize - Dimen.margin.regularExtra)/2
        self.albumSize = CGSize(width: w, height: w * Dimen.item.albumList.height / Dimen.item.albumList.width)
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .getAlbumPictures(id: self.currentId, .user, page: 1, size: 2)))
        
        
    }
    private func reset(){
        self.albums = []
        self.albumDataSets = []
    }
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [PictureData] else { return }
        
        
        var added:[AlbumListItemData] = []
        let start = 0
        let end = max(2,datas.count)
        added = zip(start...end, datas).map { idx, d in
            return AlbumListItemData().setData(d,  idx: idx, isMine: true)
        }
        self.albums.append(contentsOf: added)
        self.setupAlbumDataSet(added: added)
        if self.albums.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
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

    private func moveAlbum(){
        
    }
}


