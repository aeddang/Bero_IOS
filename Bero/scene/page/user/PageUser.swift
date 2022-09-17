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
extension PageUser{
    static let userProfileHeight:CGFloat = 232
    static let innerScrollHeight:CGFloat = 300
}
struct PageUser: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    let buttons = [String.button.album, String.button.information]
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
                    if let user = self.user {
                        ZStack{
                            UserProfileTopInfo(profile: user.currentProfile)
                                .padding(.horizontal, Dimen.app.pageHorinzontal)
                                .frame(height: self.originTopHeight)
                               
                        }
                        .frame(height: self.topHeight)
                        .padding(.top, Dimen.margin.medium * (self.topHeight/self.originTopHeight))
                        .opacity(self.topHeight/self.originTopHeight)
                        if !self.dataProvider.user.isSameUser(user) {
                            FriendFunctionBox(user: user)
                                .padding(.horizontal, Dimen.app.pageHorinzontal)
                                .padding(.top, Dimen.margin.regular)
                        }
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
                            UsersDogSection( user:user )
                            .padding(.top, Dimen.margin.regular)
                            
                            UserHistorySection(
                                user: user
                            )
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                            .padding(.top, Dimen.margin.mediumUltra)
                            
                            FriendSection(
                                user: user,
                                listSize: geometry.size.width - (Dimen.app.pageHorinzontal*2)
                            )
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                            .padding(.top, Dimen.margin.mediumUltra)
                            
                            AlbumSection(
                                user: user,
                                listSize: geometry.size.width - (Dimen.app.pageHorinzontal*2)
                            )
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                            .padding(.top, Dimen.margin.mediumUltra)
                        }
                        .background(Color.brand.bg)
                    } else {
                        Spacer()
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.infinityScrollModel.$scrollPosition){ scrollPos  in
                if SystemEnvironment.isTablet {return}
                if scrollPos > 0 {return}
                self.topHeight = max(self.originTopHeight + scrollPos, 0)
            }
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .getUserDetail(let userId):
                    if userId == self.userId , let data = res.data as? UserData{
                        self.user = User().setData(data:data)
                        self.setupTopHeight(geometry: geometry)
                    }
                default : break
                }
            }
            .onReceive(self.dataProvider.$error){err in
                guard let err = err else { return }
                if !err.id.hasPrefix(self.tag) {return}
                switch err.type {
                case .getUserDetail :
                    if userId == self.userId{
                        self.pageObservable.isInit = true
                        
                    }
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let user = obj.getParamValue(key: .data) as? User{
                    self.user = user
                    self.userId = user.snsUser?.snsID
                    self.setupTopHeight(geometry: geometry)
                    return
                }
                
                if let userId = obj.getParamValue(key: .id) as? String{
                    self.userId = userId
                    self.dataProvider.requestData(q: .init(id:self.tag, type: .getUserDetail(userId:userId)))
                    return
                }
                self.pageObservable.isInit = true
            }
        }//GeometryReader
    }//body
    @State var userId:String? = nil
    @State var user:User? = nil
    @State var menuIdx:Int = 0
    @State var topHeight:CGFloat = Self.userProfileHeight
    @State var originTopHeight:CGFloat = Self.userProfileHeight

    private func setupTopHeight(geometry:GeometryProxy){
        guard let text = self.user?.currentProfile.introduction else {
            self.originTopHeight = Self.userProfileHeight
            return
        }
        let w = geometry.size.width - 2*(Dimen.app.pageHorinzontal + VerticalProfile.descriptionPadding)
        let textH = VerticalProfile.descriptionStyle.textModifier.getTextHeight(text, screenWidth: w)
        let addTextHeight = textH - VerticalProfile.descriptionStyle.textModifier.size
        self.originTopHeight = Self.userProfileHeight + addTextHeight
        self.topHeight = max(self.originTopHeight + self.infinityScrollModel.scrollPosition, 0)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
            self.pageObservable.isInit = true
        }
    }
    
}


#if DEBUG
struct PageUser_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageUser().contentBody
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

