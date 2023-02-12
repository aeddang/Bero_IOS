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

struct PageFriend: PageView {
    
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
                        title: self.title ?? self.sortType.text,
                        useBack:true,
                        buttons: self.isMe ? self.sortType.buttons : [],
                        icons: self.sortType == .friend ? [self.hasRequested ? "N" : nil] : [],
                        action:{ type in
                            switch type {
                            case .back :
                                if self.sortType == self.originSortType {
                                    self.pagePresenter.closePopup(self.pageObject?.id)
                                } else {
                                    withAnimation{
                                        self.sortType = self.originSortType
                                    }
                                    self.onReload()
                                }
                                
                            case .addFriend :
                                self.sortType = .requested
                                self.onReload()
                            case .friend :
                                self.sortType = .friend
                                self.onReload()
                            case .more : self.onSort()
                            default : break
                            }
                        }
                    )
                    
                    if let user = self.user {
                        FriendList(
                            pageObservable: self.pageObservable,
                            infinityScrollModel: self.infinityScrollModel,
                            type:self.sortType,
                            user:user,
                            listSize: geometry.size.width,
                            isEdit: self.isEdit
                        )
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
                if res.id != self.tag {return}
                switch res.type {
                case .getRequestedFriend :
                    guard let datas = res.data as? [FriendData] else { return }
                    self.hasRequested = !datas.isEmpty
                    
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.sortType = obj.getParamValue(key: .type) as? FriendList.ListType ?? .friend
                self.originSortType = self.sortType
                self.user = obj.getParamValue(key: .data) as? User ?? self.dataProvider.user
                self.isMe = self.user?.isMe ?? false
                if self.isMe {
                    self.isEdit = obj.getParamValue(key: .isEdit) as? Bool ?? false
                    self.dataProvider.requestData(q: .init(id: self.tag, type:.getRequestedFriend(page: 0)))
                } else if let name = self.user?.representativeName {
                    self.title = String.pageTitle.usersFriends.replace(name)
                }
            }
        }//GeometryReader
    }//body
    @State var hasRequested:Bool = false
    @State var user:User? = nil
    @State var originSortType:FriendList.ListType = .friend
    @State var sortType:FriendList.ListType = .friend
    @State var isMe:Bool = false
    @State var isEdit:Bool = false
    @State var title:String? = nil
    private func onSort(){
        let datas:[String] = [
            FriendList.ListType.friend.text,
            FriendList.ListType.requested.text,
            FriendList.ListType.request.text
        ]
        self.appSceneObserver.radio = .sort( (self.tag, datas), title: String.pageText.walkHistorySeletReport){ idx in
            guard let idx = idx else {return}
            switch idx {
            case 0 : self.sortType = .friend
            case 1 : self.sortType = .requested
            case 2 : self.sortType = .request
            default : return
            }
            self.onReload()
        }
    }
    
    private func onReload(){
        if self.sortType == .requested {
            self.hasRequested = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
            self.infinityScrollModel.uiEvent = .reload
        }
    }
}


#if DEBUG
struct PageFriend_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageFriend().contentBody
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

