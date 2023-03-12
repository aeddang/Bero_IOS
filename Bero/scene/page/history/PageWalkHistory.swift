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
struct PageWalkHistory: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var calenderModel: CalenderModel = CalenderModel()
    
    struct WalkHistoryTop: PageView {
        @EnvironmentObject var pagePresenter:PagePresenter
        var calenderModel: CalenderModel
        var user:User
        var body: some View {
            VStack(spacing: 0){
                TotalWalkSection(user: user)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                SelectButton(
                    type: .tiny,
                    icon: Asset.icon.chart,
                    text: String.pageTitle.walkReport,
                    isSelected: false
                ){_ in
                    
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.walkReport)
                            .addParam(key: .data, value: user)
                    )
                }
                .padding(.horizontal, Dimen.app.pageHorinzontal)
                .padding(.top, Dimen.margin.regular)
                Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                    .padding(.top, Dimen.margin.medium)
                CPCalendar(
                    viewModel: self.calenderModel
                )
                .padding(.top, Dimen.margin.thin)
                .padding(.horizontal, Dimen.app.pageHorinzontal)
                
                Spacer().modifier(LineHorizontal())
            }
        }
    }
    
    
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
                    if let user = self.user {
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            axes: .vertical,
                            showIndicators : false,
                            header :WalkHistoryTop(calenderModel: self.calenderModel, user: user),
                            headerSize: 520,
                            
                            marginTop: Dimen.margin.regular,
                            marginBottom: Dimen.margin.medium,
                            marginHorizontal: Dimen.app.pageHorinzontal,
                            spacing:Dimen.margin.regular,
                            isRecycle: true,
                            useTracking: true
                        ){
                            MonthlyWalkSection(
                                pageObservable: self.pageObservable,
                                calenderModel: self.calenderModel,
                                user: user ,
                                listSize: geometry.size.width - (Dimen.app.pageHorinzontal*2)
                            )
                        }
                        
                    } else {
                        Spacer().modifier(MatchParent())
                    }
                    
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .getUserDetail(let userId):
                    if userId == self.userId , let data = res.data as? UserData{
                        self.user = User().setData(data:data)
                    }
                    self.pageObservable.isInit = true
                default : break
                }
            }
            .onReceive(self.dataProvider.$error){err in
                guard let err = err else { return }
                if !err.id.hasPrefix(self.tag) {return}
                switch err.type {
                case .getUserDetail:
                    self.pageObservable.isInit = true
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let user = obj.getParamValue(key: .data) as? User{
                    self.user = user
                    self.userId = user.snsUser?.snsID
                    self.pageObservable.isInit = true
                    return
                }
                if let userId = obj.getParamValue(key: .id) as? String{
                    self.userId = userId
                    self.dataProvider.requestData(q: .init(id:self.tag, type: .getUserDetail(userId:userId)))
                }
            }
        }//GeometryReader
       
    }//body
   
    @State var userId:String? = nil
    @State var user:User? = nil
   
}


#if DEBUG
struct PageWalkHistory_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWalkHistory().contentBody
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

