//
//  PageTest.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit
import Combine
import Firebase
import FacebookLogin
import FirebaseCore
import GoogleSignInSwift
struct PageBlockUser: PageView {
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(alignment: .leading, spacing: 0 ){
                    TitleTab(
                        infinityScrollModel: self.infinityScrollModel,
                        title: String.pageTitle.blockUser,
                        useBack: true, action: { type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        })
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
                            marginVertical: Dimen.margin.medium,
                            marginHorizontal: Dimen.app.pageHorinzontal,
                            spacing:Dimen.margin.regularExtra,
                            isRecycle: true,
                            useTracking: true
                        ){
                            
                            ForEach(self.users) { user in
                                BlockUserItem(data:user)
                                    .onAppear{
                                        if user.index == (self.users.count-1) {
                                            self.infinityScrollModel.event = .bottom
                                        }
                                    }
                            }
                        }
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
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
                switch res.type {
                case .getBlockedUser(let page, _):
                    if page == 0 {
                        self.resetScroll()
                    }
                    self.loaded(res)
                    
                case .blockUser :
                    self.updateUser()
                default : break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.updateUser()
                }
            }
            .onAppear(){
                
            }
        }//GeometryReader
       
    }//body
    
    @State var users:[BlockUserItemData] = []
    @State var isEmpty:Bool = false
    private func updateUser(){
        self.resetScroll()
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
                .getBlockedUser(page: self.infinityScrollModel.page) ))
        
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [UserData] else { return }
        self.loadedUser(datas: datas)
    }
    
    private func loadedUser(datas:[UserData]){
        var added:[BlockUserItemData] = []
        let start = self.users.count
        let end = start + datas.count
        added = zip(start...end, datas).map{ idx, d in
            return BlockUserItemData().setData(d,  idx: idx)
        }
        self.users.append(contentsOf: added)
        if self.users.isEmpty {
            withAnimation{ self.isEmpty = true }
        }
        self.infinityScrollModel.onComplete(itemCount: added.count)
    }
    
    
}


#if DEBUG
struct PageBlockUser_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageBlockUser().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

