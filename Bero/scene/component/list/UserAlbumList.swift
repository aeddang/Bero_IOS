//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI

struct UserAlbumList: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @Binding var type:AlbumApi.SearchType
    var listSize:CGFloat = 300
    var marginTop:CGFloat = 0
    var marginBottom:CGFloat = Dimen.margin.medium
    var body: some View {
        VStack(spacing:0){
            if self.isEmpty {
                EmptyItem(type: .myList)
                    .padding(.top, Dimen.margin.regularUltra)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                FillButton(
                    type: .fill,
                    text: String.button.returnToAllPosts,
                    color: Color.app.black
                    
                ){_ in
                    self.type = .all
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                        self.infinityScrollModel.uiEvent = .reload
                    }
                }
                .padding(.top, Dimen.margin.regularExtra)
                .padding(.horizontal, Dimen.app.pageHorinzontal)
                Spacer().modifier(MatchParent())
            } else {
                InfinityScrollView(
                    viewModel: self.infinityScrollModel,
                    axes: .vertical,
                    showIndicators : false,
                    marginTop: self.marginTop,
                    marginBottom: self.marginBottom,
                    marginHorizontal: 0,
                    spacing:Dimen.margin.regularUltra,
                    isRecycle: true,
                    useTracking: true
                ){
                    ForEach(self.users) { data in
                        UserAlbumListItem(data: data, imgSize: self.albumSize)
                        .onAppear{
                            if data.index == (self.users.count-1) {
                                self.infinityScrollModel.event = .bottom
                            }
                        }
                        Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                    }
                    
                }
            }
        }
        .onReceive(self.infinityScrollModel.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .bottom : self.loadUser()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$uiEvent){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .reload :
                if self.infinityScrollModel.isLoading {return}
                self.updateUser()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            switch res.type {
            case .getAlbumExplorer(let randId, let type, let page, _):
                if !res.id.hasPrefix(self.tag) {return}
                if self.randId != randId {return}
                if self.type == type {
                    if page == 0 {
                        self.resetScroll()
                    }
                    self.loaded(res)
                }
            case .blockUser , .registAlbumPicture :
                self.updateUser()
            default : break
            }
        }
        .onAppear(){
            self.updateUser()
        }
    }
    
    
    @State var randId:String = UUID().uuidString
    @State var isEmpty:Bool = false
    @State var users:[UserAlbumListItemData] = []
    @State var albumSize:CGSize = .zero
    private func updateUser(){
        let yyyyMMdd = AppUtil.networkTimeDate().timeIntervalSince1970.toInt().description
        self.randId = yyyyMMdd
        self.resetScroll()
        let w = self.listSize
        self.albumSize = CGSize(width: w, height: w * Dimen.item.albumList.height / Dimen.item.albumList.width)
        self.loadUser()
        
    }
    
    private func resetScroll(){
        withAnimation{ self.isEmpty = false }
        self.users = []
        self.infinityScrollModel.reload()
    }
    
    func loadUser(){
        if self.infinityScrollModel.isLoading {return}
        if self.infinityScrollModel.isCompleted {return}
        self.infinityScrollModel.onLoad()
        
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .getAlbumExplorer(
                    randId: self.randId,
                    searchType: self.type,page: self.infinityScrollModel.page) ))
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [PictureData] else { return }
        self.loadedUser(datas: datas)
    }
    
    private func loadedUser(datas:[PictureData]){
        var added:[UserAlbumListItemData] = []
        let start = self.users.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return UserAlbumListItemData().setData(d,  idx: idx)
        }
        self.users.append(contentsOf: added)
        if self.users.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }

}


