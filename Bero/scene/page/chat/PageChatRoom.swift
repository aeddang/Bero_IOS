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
    @EnvironmentObject var sceneObserver:PageSceneObserver
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
                        buttons:[.more]){ type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            case .more : self.more()
                            default : break
                            }
                    }
                    if let id = self.userId {
                        ChatList(
                            infinityScrollModel: self.infinityScrollModel,
                            userId: id,
                            roomData: self.roomData,
                            userName: self.$userName
                        )
                    }
                    else {
                        Spacer().modifier(MatchParent())
                    }
                }
                .padding(.bottom, Dimen.tab.medium + self.sceneObserver.safeAreaIgnoreKeyboardBottom)
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
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
                //if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .deleteChatRoom :
                    self.pagePresenter.closePopup(self.pageObject?.id)
                case .blockUser :
                    self.pagePresenter.closePopup(self.pageObject?.id)
                default : break
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
    @State var userName:String? = nil
    @State var title:String? = nil
   
    private func more(){
        
        let datas:[String] = [
            String.button.deleteRoom,
            String.button.block,
            String.button.accuseUser
        ]
        let icons:[String?] = [
            Asset.icon.delete,
            Asset.icon.block,
            Asset.icon.warning
        ]
       
        self.appSceneObserver.radio = .select((self.tag, icons, datas), title: String.alert.supportAction){ idx in
            guard let idx = idx else {return}
            switch idx {
            case 0 :self.delete()
            case 1 : self.block()
            case 2 : self.accuse()
            default : break
            }
        }
    }
    
    private func delete(){
        guard let roomId = self.roomData?.roomId else {return}
        self.appSceneObserver.sheet = .select(
            String.alert.chatRoomDeleteConfirm,
            String.alert.chatRoomDeleteConfirmText,
            [String.app.cancel,String.button.delete],
            isNegative: true){ idx in
                if idx == 1 {
                    self.dataProvider.requestData(q: .init(type: .deleteChatRoom(roomId:roomId)))
                }
        }
    }
    private func block(){
        
        self.appSceneObserver.sheet = .select(
            String.alert.blockUserConfirm.replace(self.userName ?? ""),
            nil,
            [String.app.cancel,String.button.block],
            isNegative: true){ idx in
                if idx == 1 {
                    self.dataProvider.requestData(q: .init(type: .blockUser(userId: self.userId ?? "", isBlock: true)))
                }
        }
    }
    
    private func accuse(){
        self.appSceneObserver.sheet = .select(
            String.alert.accuseUserConfirm.replace(self.userName ?? ""),
            String.alert.accuseUserConfirmText,
            [String.app.cancel,String.button.accuseUser],
            isNegative: true){ idx in
                if idx == 1 {
                    self.sendReport()
                }
            }
    }
    
    private func sendReport(){
        self.dataProvider.requestData(q: .init(type: .sendReport(
            reportType: .user, postId: self.roomData?.roomId.description, userId: self.userId
        )))
    }
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

