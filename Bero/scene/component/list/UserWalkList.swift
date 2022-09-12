//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI

struct UserWalkList: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @Binding var type:MissionApi.SearchType
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
                    self.type = .User
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
                        UserListItem(data: data, imgSize: self.albumSize)
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
            case .reload : self.updateUser()
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .searchMission(_, let type, _, _, _, let page, _):
                if self.type == type {
                    if page == 0 {
                        self.resetScroll()
                    }
                    self.loaded(res)
                }
            default : break
            }
        }
        .onAppear(){
            self.updateUser()
        }
    }
    
    
    
    @State var isEmpty:Bool = false
    @State var users:[UserListItemData] = []
    @State var albumSize:CGSize = .zero
    private func updateUser(){
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
        
        var distance:Double? = nil
        switch self.type {
        case .Distance : distance = WalkManager.distenceUnit
        default : break
        }
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .searchMission(.all, self.type,
                               location: self.walkManager.currentLocation,
                               distance: distance,
                               page: self.infinityScrollModel.page) ))
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [MissionData] else { return }
        self.loadedUser(datas: datas)
    }
    
    private func loadedUser(datas:[MissionData]){
        var added:[UserListItemData] = []
        let start = self.users.count
        let end = start + datas.count
        added = zip(start...end, datas).map { idx, d in
            return UserListItemData().setData(d,  idx: idx)
        }
        self.users.append(contentsOf: added)
        if self.users.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }

}


