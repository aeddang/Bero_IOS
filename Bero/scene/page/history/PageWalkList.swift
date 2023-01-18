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

struct PageWalkList: PageView {
    
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
                        title: String.pageTitle.walkHistory,
                        useBack: true, action: { type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        })
                    if let userId = self.userId {
                        WalkList(
                            pageObservable: self.pageObservable,
                            infinityScrollModel: self.infinityScrollModel,
                            userId: userId,
                            isFriend: self.isFriend,
                            listSize: geometry.size.width
                        )
                    } else {
                        EmptyItem(type: .myList)
                            .padding(.top, Dimen.margin.regularUltra)
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                        Spacer().modifier(MatchParent())
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let isFriend = obj.getParamValue(key: .isFriend) as? Bool{
                    self.isFriend = isFriend
                }
                if let userId = obj.getParamValue(key: .id) as? String{
                    self.userId = userId
                    return
                }
                
                self.pageObservable.isInit = true
            }
        }//GeometryReader
    }//body
    
    @State var userId:String? = nil
    @State var isFriend:Bool = false
}


#if DEBUG
struct PageWalkList_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWalkList().contentBody
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

