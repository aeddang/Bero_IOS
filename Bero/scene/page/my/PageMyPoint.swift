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
struct PageMyPoint: PageView {
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
                        title: String.pageTitle.myPoint,
                        useBack: true,
                        action: { type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        })
                    
                    PointSection(
                        user: self.dataProvider.user
                    )
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    .padding(.top, Dimen.margin.regularExtra)
                    
                    Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                        .padding(.top, Dimen.margin.medium)
                    TitleSection(
                        title: String.pageText.earningHistory,
                        trailer: String.pageText.myPointText1
                    )
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    .padding(.top, Dimen.margin.regularExtra)
                    Spacer().modifier(LineHorizontal(height: Dimen.line.light))
                        .padding(.top, Dimen.margin.regularExtra)
                    RewardHistoryList(
                        infinityScrollModel:self.infinityScrollModel,
                        type: .point,
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
struct PageMyPoint_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyPoint().contentBody
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

