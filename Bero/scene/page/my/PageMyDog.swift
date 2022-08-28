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
struct PageMyDog: PageView {
    enum ViewType{
        case info, album
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    let buttons = [String.button.information, String.button.album]
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(alignment: .leading, spacing: 0 ){
                    TitleTab(
                        useBack: true
                    ){ type in
                        switch type {
                        case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                        default : break
                        }
                    }
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    if let profile = self.profile {
                        PetProfileTopInfo(profile: profile){
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.modifyPet)
                                    .addParam(key: .data, value: profile)
                            )
                        }
                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                        .padding(.top, Dimen.margin.medium)
                        MenuTab(
                            viewModel:self.navigationModel,
                            type: .line,
                            buttons: self.buttons,
                            selectedIdx: self.menuIdx
                        )
                        .padding(.top, Dimen.margin.medium)
                        switch self.viewType {
                        case .album :
                            AlbumList(
                                infinityScrollModel: self.infinityScrollModel,
                                profile:profile,
                                listSize: geometry.size.width - (Dimen.app.pageHorinzontal*2)
                            )
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                          
                        case .info :
                            InfinityScrollView(
                                viewModel: self.infinityScrollModel,
                                axes: .vertical,
                                showIndicators : false,
                                marginVertical: Dimen.margin.medium,
                                marginHorizontal: 0,
                                spacing:0,
                                isRecycle: false,
                                useTracking: false
                            ){
                                MyPetTagSection(
                                    profile: profile,
                                    listSize: geometry.size.width - (Dimen.app.pageHorinzontal*2)
                                )
                                .padding(.horizontal, Dimen.app.pageHorinzontal)
                                .padding(.top, Dimen.margin.regular)
                                MyPetPhysicalSection(
                                    profile: profile
                                )
                                .padding(.horizontal, Dimen.app.pageHorinzontal)
                                .padding(.top, Dimen.margin.mediumUltra)
                                Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                                    .padding(.top, Dimen.margin.medium)
                                
                                MyPetHistorySection(profile:profile)
                                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                                    .padding(.top, Dimen.margin.medium)
                            }
                        }
                        
                    } else {
                        Spacer()
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.navigationModel.$index){ idx in
                if idx == 0 {
                    self.viewType = .info
                } else {
                    self.viewType = .album
                }
                withAnimation{
                    self.menuIdx = idx
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let profile = obj.getParamValue(key: .data) as? PetProfile{
                    self.profile = profile
                }
            
            }
        }//GeometryReader
       
    }//body
    @State var profile:PetProfile? = nil
    @State var viewType:ViewType = .info
    @State var menuIdx:Int = 0
}


#if DEBUG
struct PageMyDog_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyDog().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

