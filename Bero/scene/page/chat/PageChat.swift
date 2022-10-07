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
                        title: String.pageTitle.chat,
                        buttons:[.setting]){ type in
                        switch type {
                        case .setting :
                            withAnimation{
                                self.isEdit.toggle()
                            }
                        default : break
                        }
                    }
                    
                    ChatRoomList(
                        infinityScrollModel: self.infinityScrollModel,
                        isEdit: self.$isEdit)
                    
                    Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                    FriendListSection(
                        pageObservable:self.pageObservable,
                        infinityScrollModel : self.friendScrollModel,
                        user:self.dataProvider.user
                    )
                    .padding(.top, Dimen.margin.regular)
                    .padding(.bottom, self.bottomMargin)
                }
                .padding(.bottom, Dimen.app.bottom)
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
               
                switch res.type {
                case .sendChat :
                    if self.pagePresenter.currentTopPage == self.pageObject {
                        self.infinityScrollModel.uiEvent = .reload
                    }
                default : break
                }
            }
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

