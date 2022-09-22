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
                        useBack: true,
                        action: { type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        }
                    )
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
                            PetTagSection(
                                profile: profile,
                                listSize: geometry.size.width - (Dimen.app.pageHorinzontal*2)
                            )
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                            .padding(.top, Dimen.margin.regular)
                            PetPhysicalSection(
                                profile: profile
                            )
                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                            .padding(.top, Dimen.margin.mediumUltra)
                            Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                                .padding(.top, Dimen.margin.medium)
                            if let user = self.user {
                                PetHistorySection(
                                    user:user,
                                    profile:profile)
                                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                                    .padding(.top, Dimen.margin.medium)
                                
                                AlbumSection(
                                    user: user,
                                    listSize: geometry.size.width - (Dimen.app.pageHorinzontal*2)
                                )
                                .padding(.horizontal, Dimen.app.pageHorinzontal)
                                .padding(.top, Dimen.margin.mediumUltra)
                            }
                        }
                        .background(Color.brand.bg)
                    } else {
                        Spacer()
                    }
                    if !self.dataProvider.user.isSameUser(self.user) , let user = self.user?.currentProfile {
                        UserProfileItem(
                            data: user,
                            subImagePath: self.profile?.imagePath,
                            useBg: true,
                            action:self.moveUser
                        )
                        .modifier(ShadowTop())
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
                case .getPet(let petId) :
                    if petId == self.currentPetId, let data = res.data as? PetData{
                        self.profile = PetProfile(data: data)
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.05){
                            self.pageObservable.isInit = true
                            self.getUser()
                        }
                    }
                case .getUserDetail(let userId):
                    if userId == self.currentUserId , let data = res.data as? UserData{
                        self.user = User().setData(data:data)
                    }
                default : break
                }
            }
            .onReceive(self.dataProvider.$error){err in
                guard let err = err else { return }
                if !err.id.hasPrefix(self.tag) {return}
                switch err.type {
                case .getPet(let petId) :
                    if petId == self.currentPetId{
                        self.pageObservable.isInit = true
                    }
                default : break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ isAni in
                if isAni {
                    self.getUser()
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let user = obj.getParamValue(key: .subData) as? User{
                    self.fromUserPage = true
                    self.user = user
                }
                if let profile = obj.getParamValue(key: .data) as? PetProfile{
                    self.profile = profile
                    self.setupTopHeight(geometry: geometry)
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                        self.pageObservable.isInit = true
                        if self.pageObservable.isAnimationComplete {
                            self.getUser()
                        }
                    }
                    return
                }
                
                if let petId = obj.getParamValue(key: .id) as? Int{
                    self.currentPetId = petId
                    self.dataProvider.requestData(q: .init(id:self.tag, type: .getPet(petId: petId)))
                    return
                }
                self.pageObservable.isInit = true
            
            }
        }//GeometryReader
       
    }//body
    @State var currentPetId:Int = -1
    @State var currentUserId:String = ""
    @State var user:User? = nil
    @State var profile:PetProfile? = nil
    @State var menuIdx:Int = 0
    @State var topHeight:CGFloat = Self.height
    @State var originTopHeight:CGFloat = Self.height
    @State var fromUserPage:Bool = false
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
    private func getUser(){
        if self.user == nil, let id = self.profile?.userId {
            self.currentUserId = id
            self.dataProvider.requestData(q: .init(id:self.tag, type: .getUserDetail(userId:id)))
        }
    }
    
    private func moveUser(){
        guard let user = self.user else { return }
        if self.fromUserPage {
            self.pagePresenter.closePopup(self.pageObject?.id)
            return
        }
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.user)
                .addParam(key: .data, value:user)
        )
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

