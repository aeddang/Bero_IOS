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
                        useBack:true
                    ){ type in
                        switch type {
                        case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                        default : break
                        }
                    }
                    HStack(spacing:0){
                        TitleSection(
                            title: String.pageTitle.friends
                        )
                        SortButton(
                            type: .stroke,
                            sizeType: .big,
                            text: self.sortType.text,
                            color:Color.app.grey400,
                            isSort: true){
                                self.onSort()
                            }
                            .fixedSize()
                    }
                    .padding(.top, Dimen.margin.regularExtra)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    if let user = self.user {
                        FriendList(
                            pageObservable: self.pageObservable,
                            infinityScrollModel: self.infinityScrollModel,
                            type:self.sortType,
                            user:user,
                            listSize: geometry.size.width
                        )
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let user = obj.getParamValue(key: .data) as? User{
                    self.user = user
                    return
                }
                self.pageObservable.isInit = true
            }
        }//GeometryReader
    }//body
    @State var user:User? = nil
    @State var sortType:FriendList.ListType = .friend
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
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                self.infinityScrollModel.uiEvent = .reload
            }
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

