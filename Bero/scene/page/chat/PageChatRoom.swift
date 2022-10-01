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

struct PageChatRoom: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
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
                        title: self.title,
                        useBack: true,
                        buttons:[]){ type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                    }
                    if let id = self.userId {
                        ChatList(
                            infinityScrollModel: self.infinityScrollModel,
                            userId: id,
                            roomData: self.roomData
                        )
                    }
                    else {
                        Spacer().modifier(MatchParent())
                    }
                }
                .padding(.bottom, Dimen.tab.medium)
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.pageObservable.$isAnimationComplete) { isOn in
                if isOn {
                    
                    if let data = self.roomData{
                        self.userId = data.userId
                        self.appSceneObserver.event =
                            .setupChat(userId: self.userId ?? "", isFocus: false, isActive: true)
                    }
                }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if page == self.pageObject {
                    guard let id = self.userId else {return}
                    self.appSceneObserver.event =
                        .setupChat(userId: id, isFocus: false, isActive: true)
                    return
                }
                if page?.pageID != .chatRoom {
                    self.appSceneObserver.event =
                        .setupChat(userId: "", isFocus: false, isActive: false)
                }
                
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .data) as? ChatRoomListItemData{
                    self.roomData = data
                    self.title = data.title
                }
            }
            .onDisappear(){
                if !self.pagePresenter.hasPopup(find: .chatRoom) {
                    self.appSceneObserver.event =
                        .setupChat(userId: "", isFocus: false, isActive: false)
                }
            }
        }//GeometryReader
    }//body
    @State var roomData:ChatRoomListItemData? = nil
    @State var userId:String? = nil
    @State var title:String? = nil
   
}

#if DEBUG
struct PageChatRoom_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageChatRoom().contentBody
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

