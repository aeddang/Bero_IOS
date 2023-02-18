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

struct PageChat: PageView {
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @ObservedObject var friendScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var reloadDegree:Double = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(alignment: .leading, spacing: 0 ){
                    TitleTab(
                        infinityScrollModel: self.infinityScrollModel,
                        title: self.isEdit ? String.button.manageChat : String.pageTitle.chat,
                        useBack: self.isEdit,
                        buttons:self.isEdit ? [] : [.friend, .setting]){ type in
                        switch type {
                        case .back :
                            withAnimation{
                                self.isEdit = false
                            }
                        case .friend :
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.friend)
                                    .addParam(key: .type, value: FriendList.ListType.chat)
                            )
                        case .setting :
                            withAnimation{
                                self.isEdit = true
                            }
                        default : break
                        }
                    }
                    ZStack(alignment: .top){
                        ChatRoomList(
                            infinityScrollModel: self.infinityScrollModel,
                            isEdit: self.$isEdit)
                        ReflashSpinner(
                            progress: self.reloadDegree
                        )
                    }
                   
                }
                .padding(.bottom, Dimen.app.bottom)
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                if pos < InfinityScrollModel.PULL_RANGE { return }
                self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
            }
            .onReceive(self.infinityScrollModel.$event){evt in
                  guard let evt = evt else {return}
                  switch evt {
                  case .pullCompleted :
                    self.infinityScrollModel.uiEvent = .reload
                    withAnimation{
                            self.reloadDegree = 0
                        }
                  case .pullCancel :
                    withAnimation{
                        self.reloadDegree = 0
                    }
                  default : break
                  }
            }
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
               
                switch res.type {
                case .sendChat :
                    if self.pagePresenter.currentTopPage?.pageID != .chatRoom {
                        self.infinityScrollModel.uiEvent = .reload
                        self.pagePresenter.closeAllPopup()
                    }
                default : break
                }
            }
            /*
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if page == self.pageObject {
                    self.infinityScrollModel.uiEvent = .reload
                }
            }*/
            .onReceive(self.walkManager.$status) { status in
                switch status {
                case .walking : self.bottomMargin = Dimen.app.bottom
                case .ready : self.bottomMargin = 0
                }
            }
            .onAppear{
                
            }
        }//GeometryReader
    }//body
    @State var isEdit:Bool = false
    @State var bottomMargin:CGFloat = 0
}


#if DEBUG
struct PageChat_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageChat().contentBody
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

