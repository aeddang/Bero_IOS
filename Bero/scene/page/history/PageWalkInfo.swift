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

extension PageWalkInfo {
    static let topScrollDefault:CGFloat = 240
    static let topScrollMax:CGFloat = 320
}

struct PageWalkInfo: PageView {
    
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
                        title: self.title ,
                        useBack: true, action: { type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        })
                    .zIndex(999)
                    ZStack(alignment: .top){
                        ZStack(alignment: .topTrailing){
                            if let path = self.mission?.pictureUrl {
                                ImageView(url: path,
                                          contentMode: .fill,
                                          noImg: Asset.noImg1_1 )
                                .frame(
                                    width: geometry.size.width * max(1.0,self.imageScale),
                                    height: geometry.size.width * max(1.0,self.imageScale)
                                )
                                .opacity(max(self.imageScale, 0.2))
                                .frame(
                                    width: geometry.size.width ,
                                    height: geometry.size.width
                                )
                            } else {
                                Image(Asset.noImg1_1)
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .modifier(MatchParent())
                            }
                            if self.isMe, let pets = self.mission?.user?.pets {
                                HStack(spacing:Dimen.margin.micro){
                                    ForEach(pets) { profile in
                                        Button(action: {
                                           
                                            self.pagePresenter.openPopup(
                                                PageProvider.getPageObject(.dog)
                                                    .addParam(key: .id, value: profile.petId)
                                            )
                                        }) {
                                            ProfileImage(
                                                image:profile.image,
                                                imagePath: profile.imagePath,
                                                isSelected: true,
                                                strokeColor: Color.app.white,
                                                size: Dimen.profile.thin,
                                                emptyImagePath: Asset.image.profile_dog_default
                                            )
                                        }
                                    }
                                }
                                .fixedSize()
                                .padding(.all, Dimen.margin.regular)
                            } else if !self.isMe ,
                                let userId = self.user?.userId ?? self.userProfile?.userId ,
                                let img = self.user?.representativeImage ?? self.userProfile?.imagePath {
                                    Button(action: {
                                        self.pagePresenter.openPopup(
                                            PageProvider.getPageObject(.user)
                                                .addParam(key: .id, value:userId)
                                                .addParam(key:.data, value: self.user)
                                        )
                                        
                                    }) {
                                        ProfileImage(
                                            imagePath: img,
                                            isSelected: true,
                                            strokeColor: Color.app.white,
                                            size: Dimen.profile.thin,
                                            emptyImagePath: Asset.image.profile_dog_default
                                        )
                                    }
                                    .padding(.all, Dimen.margin.regular)
                                
                            }
                                    
                        }
                        .modifier(MatchHorizontal(height: geometry.size.width))
                        .clipped()
                        VStack(spacing:0){
                            Spacer().frame(
                                width: 0,
                                height: max(0,Self.topScrollDefault + self.topOffSet)
                            )
                            ZStack{
                                if let mission = self.mission {
                                    InfinityScrollView(
                                        viewModel: self.infinityScrollModel,
                                        axes: .vertical,
                                        showIndicators : false,
                                        marginTop: Dimen.margin.regular,
                                        marginBottom: Dimen.margin.medium,
                                        marginHorizontal: 0,
                                        spacing:0,
                                        isRecycle: false,
                                        useTracking: true
                                    ){
                                        HStack(spacing: 0){
                                            VStack(alignment: .leading, spacing: 0){
                                                Spacer().modifier(MatchHorizontal(height: 0))
                                                WalkTopInfo(mission: mission, isMe: self.isMe)
                                            }
                                            if !self.isMe, let pets = self.mission?.user?.pets {
                                                HStack(spacing:Dimen.margin.microExtra){
                                                    ForEach(pets) { profile in
                                                        ProfileImage(
                                                            image:profile.image,
                                                            imagePath: profile.imagePath,
                                                            size: Dimen.profile.tiny,
                                                            emptyImagePath: Asset.image.profile_dog_default
                                                        )
                                                    }
                                                }
                                                .fixedSize()
                                            }
                                        }
                                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                                        
                                        WalkPropertySection(mission: mission){ idx in
                                            
                                        }
                                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                                        .padding(.top, Dimen.margin.regular)
                                        
                                        WalkPlayInfo(mission: mission)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                            .padding(.top, Dimen.margin.regular)
                                            .padding(.bottom, Dimen.margin.medium)
                                        
                                        if let pictures = self.pictures {
                                            WalkAlbumSection(
                                                title: nil,
                                                listSize: geometry.size.width,
                                                albums: pictures
                                            )
                                        }
                                        
                                        
                                    }
                                    
                                } else {
                                    Spacer().modifier(MatchParent())
                                }
                            }
                            .modifier(BottomFunctionTab(margin:0, effectPct:self.imageScale))
                        }
                    }
                }
                .modifier(PageTop())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCancel : break
                    //withAnimation{ self.imageScale = 1 }
                default : break
                }
            }
            .onReceive(self.infinityScrollModel.$scrollPosition){ scrollPos  in
                if !self.useScrollUi {return}
                self.imageScale = 1.0 + (scrollPos*0.01)
                if scrollPos > 0 {return}
                PageLog.d("scrollPos " + scrollPos.description, tag: self.tag)
                self.topOffSet = max(scrollPos, -Self.topScrollMax)
            }
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .getWalk(let walkId) :
                    if walkId != self.walkId {return}
                    self.loaded(res)
                    self.pageObservable.isInit = true
                default : break
                }
            }
            
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let mission = obj.getParamValue(key: .data) as? Mission{
                    self.mission = mission
                    self.user = mission.user
                    self.updatedData()
                    self.pageObservable.isInit = true
                    return
                } else if let user = obj.getParamValue(key: .data) as? User{
                    self.user = user
                } else if let user = obj.getParamValue(key: .data) as? UserProfile{
                    self.userProfile = user
                }
                if let walkId = obj.getParamValue(key: .id) as? Int{
                    self.walkId = walkId
                    self.dataProvider.requestData(q:.init(id:self.tag,type: .getWalk(walkId: walkId)))
                }
            }
        }//GeometryReader
    }//body
    
    @State var userProfile:UserProfile? = nil
    @State var user:User? = nil
    @State var title:String = String.pageTitle.walkSummary
    @State var walkId:Int = -1
    @State var isMe:Bool = false
    @State var mission:Mission? = nil
    @State var topOffSet:CGFloat = Dimen.margin.regular
    @State var imageScale:CGFloat = 1.0
    @State var pictures:[WalkPictureItem]? = nil
    @State var useScrollUi:Bool = false
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? WalkData else { return }
        self.mission = Mission().setData(data, userId: self.user?.userId)
        self.updatedData()
    }
    
    private func updatedData(){
        guard let mission = self.mission else {return}
        self.walkId = mission.missionId
        let userId = self.user?.userId ?? self.userProfile?.userId ?? mission.userId ??  "" //self.dataProvider.user.userId ?? ""
        self.isMe = self.dataProvider.user.isSameUser(userId: userId)
        
        self.pictures = mission.walkPath?.pictures
        self.useScrollUi = (self.pictures?.count ?? 0) > 1
    }
}


#if DEBUG
struct PageWalkInfo_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWalkInfo().contentBody
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

