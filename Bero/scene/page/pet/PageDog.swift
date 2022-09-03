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
extension PageDog{
    static let height:CGFloat = 232
}
struct PageDog: PageView {
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
                        ZStack{
                            PetProfileTopInfo(profile: profile){
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.modifyPet)
                                        .addParam(key: .data, value: profile)
                                )
                            }
                            .frame(height: self.originTopHeight)
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                        }
                        .frame(height: self.topHeight)
                        .padding(.top, Dimen.margin.medium * (self.topHeight/self.originTopHeight))
                        .opacity(self.topHeight/Self.height)
                        MenuTab(
                            viewModel:self.navigationModel,
                            type: .line,
                            buttons: self.buttons,
                            selectedIdx: self.menuIdx
                        )
                        .padding(.top, Dimen.margin.medium)
                        .background(Color.brand.bg)
                        switch self.viewType {
                        case .album :
                            AlbumList(
                                infinityScrollModel: self.infinityScrollModel,
                                user: user,
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
                                useTracking: true
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
                                
                                Spacer().frame(width: 0, height: self.originTopHeight-self.topHeight)
                                
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
                self.topHeight = self.originTopHeight
            }
            
            .onReceive(self.infinityScrollModel.$scrollPosition){ scrollPos  in
                if scrollPos > 0 {return}
                if self.viewType == .album
                    && ceil(Float(self.infinityScrollModel.total) / Float(AlbumList.row) ) < 2 {return}
                
                PageLog.d("scrollPos " + scrollPos.description, tag:self.tag)
                self.topHeight = max(self.originTopHeight + scrollPos, 0)
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let user = obj.getParamValue(key: .subData) as? User{
                    self.user = user
                }
                if let profile = obj.getParamValue(key: .data) as? PetProfile{
                    self.profile = profile
                    self.setupTopHeight(geometry: geometry)
                }
            
            }
        }//GeometryReader
       
    }//body
    @State var user:User? = nil
    @State var profile:PetProfile? = nil
    @State var viewType:ViewType = .info
    @State var menuIdx:Int = 0
    @State var topHeight:CGFloat = Self.height
    @State var originTopHeight:CGFloat = Self.height

    private func setupTopHeight(geometry:GeometryProxy){
        guard let text = self.profile?.introduction else {
            self.originTopHeight = Self.height
            return
        }
        let w = geometry.size.width - 2*(Dimen.app.pageHorinzontal + VerticalProfile.descriptionPadding)
        let textH = VerticalProfile.descriptionStyle.textModifier.getTextHeight(text, screenWidth: w)
        let addTextHeight = textH - VerticalProfile.descriptionStyle.textModifier.size
        self.originTopHeight = Self.height + addTextHeight
        self.topHeight = max(self.originTopHeight + self.infinityScrollModel.scrollPosition, 0)
    }
    
}


#if DEBUG
struct PageDog_Previews: PreviewProvider {
    static var previews: some View {
        Form{
           PageDog().contentBody
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

