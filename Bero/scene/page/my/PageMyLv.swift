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
struct PageMyLv: PageView {
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
                        title: String.pageTitle.myLv,
                        useBack: true,
                        action: { type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        })
            
                    LvSection(
                        user: self.dataProvider.user
                    )
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    .padding(.top, Dimen.margin.regularExtra)
                    
                    Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                        .padding(.top, Dimen.margin.medium)
                    
                    TitleSection(
                        title: String.pageText.earningHistory,
                        trailer: String.pageText.myLvText1
                    )
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    .padding(.top, Dimen.margin.regularExtra)
                    Spacer().modifier(LineHorizontal(height: Dimen.line.light))
                        .padding(.top, Dimen.margin.regularExtra)
                    RewardHistoryList(
                        infinityScrollModel:self.infinityScrollModel,
                        user:self.dataProvider.user)
                    
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onAppear(){
               
            }
        }//GeometryReader
    }//body
}


#if DEBUG
struct PageMyLv_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyLv().contentBody
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

