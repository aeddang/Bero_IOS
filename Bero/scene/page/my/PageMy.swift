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
struct PageMy: PageView {
    
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
                axis:.vertical
            ) {
                VStack(alignment: .leading, spacing: 0 ){
                    TitleTab(
                        infinityScrollModel: self.infinityScrollModel,
                        title: String.pageTitle.my,
                        buttons:[.setting]){ type in
                        switch type {
                        case .alram : break
                        case .setting :
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.setup)
                            )
                        default : break
                        }
                    }
                       
                   
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .vertical,
                        showIndicators : false,
                        marginTop: Dimen.margin.medium,
                        marginBottom: Dimen.app.bottom + Dimen.margin.heavyExtra,
                        marginHorizontal: 0,
                        spacing:0,
                        isRecycle: false,
                        useTracking: true
                    ){
                        if let pet = self.representativePet {
                            PetProfileTopInfo(profile:pet){
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.modifyPet)
                                        .addParam(key: .data, value: pet)
                                )
                            }
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                            
                        } else {
                            UserProfileTopInfo(profile: self.dataProvider.user.currentProfile){
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.modifyUser)
                                )
                            }
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                        }
                        
                        MyPlayInfo(){ type in
                            switch type {
                            case .value(let valueType, _) :
                                switch valueType {
                                case .heart :
                                    self.pagePresenter.openPopup(
                                        PageProvider.getPageObject(.myLv)
                                    )
                                case .point :
                                    self.appSceneObserver.event = .toast(String.alert.comingSoon)
                                default :
                                    self.appSceneObserver.event = .toast(String.alert.comingSoon)
                                }
                            default : break
                            }
                            
                        }
                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                        .padding(.top, Dimen.margin.regular)
                        Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                            .padding(.top, Dimen.margin.medium)
                        
                        MyHistorySection()
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                            .padding(.top, Dimen.margin.regular)
                        
                        MyDogsSection()
                            .padding(.top, Dimen.margin.heavyExtra)
                        
                        FriendSection(
                            user: self.dataProvider.user,
                            listSize: geometry.size.width - (Dimen.app.pageHorinzontal*2),
                            isEdit: true
                        )
                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                        .padding(.top, Dimen.margin.heavyExtra)
                        
                            
                        AlbumSection(
                            user: self.dataProvider.user,
                            listSize: geometry.size.width - (Dimen.app.pageHorinzontal*2),
                            pageSize: 2
                        )
                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                        .padding(.top, Dimen.margin.heavyExtra)
                        
                        
                       
                            
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging

            .onReceive(self.dataProvider.user.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .updatedDogs: break
                default : break
                }
            }
            .onReceive(self.dataProvider.user.$representativePet){ pet in
                self.representativePet = pet
            }
            .onAppear{
                
            
            }
        }//GeometryReader
       
    }//body
   
    @State var representativePet:PetProfile? = nil
   
}


#if DEBUG
struct PageMy_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMy().contentBody
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

