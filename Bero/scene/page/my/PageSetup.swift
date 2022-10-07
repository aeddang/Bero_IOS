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
struct PageSetup: PageView {
    @EnvironmentObject var repository:Repository
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
                        title: String.pageTitle.setup,
                        useBack: true, action: { type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        })
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .vertical,
                        showIndicators : false,
                        marginVertical: Dimen.margin.medium,
                        marginHorizontal: Dimen.app.pageHorinzontal,
                        spacing:Dimen.margin.regularExtra,
                        isRecycle: false,
                        useTracking: true
                    ){
                        RadioButton(
                            type: .switchOn,
                            isChecked: self.isReceivePush,
                            text:String.pageText.setupNotification,
                            color: Color.app.black
                        ){ _ in
                            withAnimation{
                                self.isReceivePush.toggle()
                            }
                            self.repository.setupPush(self.isReceivePush)
                        }
                        Spacer().modifier(LineHorizontal())
                        SelectButton(
                            type: .medium,
                            text: String.pageTitle.service,
                            useStroke: false,
                            useMargin: false
                        ){_ in
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.serviceTerms)
                            )
                        }
                        SelectButton(
                            type: .medium,
                            text: String.pageTitle.privacy,
                            useStroke: false,
                            useMargin: false
                        ){_ in
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.privacy)
                            )
                        }
                        SelectButton(
                            type: .medium,
                            text: String.pageTitle.blockUser,
                            useStroke: false,
                            useMargin: false
                        ){_ in
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.blockUser)
                            )
                        }
                        Spacer().modifier(LineHorizontal())
                        Spacer()
                        FillButton(
                            type: .fill,
                            text: String.button.logOut
                        ){_ in
                            self.walkManager.endWalk()
                            self.repository.clearLogin()
                        }
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onAppear(){
                self.isReceivePush = self.repository.storage.isReceivePush
            }
            
        }//GeometryReader
       
    }//body
    @State var isReceivePush:Bool = false
   
}


#if DEBUG
struct PageSetup_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageSetup().contentBody
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

