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
                                Spacer()
                                    .modifier(MatchParent())
                            }
                            if let pets = self.mission?.user?.pets {
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
                                        marginVertical: Dimen.margin.medium,
                                        marginHorizontal: 0,
                                        spacing:0,
                                        isRecycle: false,
                                        useTracking: true
                                    ){
                                        WalkTopInfo(mission: mission, isMe: self.isMe)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                        WalkPlayInfo(mission: mission)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                            .padding(.top, Dimen.margin.regularUltra)
                                        
                                        Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                                            .padding(.vertical, Dimen.margin.medium)
                                        
                                        WalkPropertySection(mission: mission)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                            .padding(.top, Dimen.margin.regularUltra)
                                        
                                        Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                                            .padding(.vertical, Dimen.margin.medium)
                                        
                                        WalkAlbumSection(
                                            listSize: geometry.size.width,
                                            albums: mission.walkPath?.pictures ?? []
                                        )
                                        
                                        
                                        /*
                                        TitleTab(type:.section, title: String.pageTitle.completedMissions)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                            .padding(.bottom, Dimen.margin.regularUltra)
                                        
                                        ForEach(self.missions) { data in
                                            RewardHistoryListItem(data: data)
                                                .padding(.horizontal, Dimen.app.pageHorinzontal)
                                                
                                            if data.index != (self.missions.count-1) {
                                                Spacer().modifier(LineHorizontal())
                                                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                                                    .padding(.vertical, Dimen.margin.regular)
                                            }
                                        }
                                        if self.missions.isEmpty {
                                            EmptyItem(type: .myList)
                                        }
                                        if self.missions.count < 3 {
                                            Spacer()
                                                .frame(height:100)
                                        }
                                        */
                                        
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
                    self.updatedData()
                    self.pageObservable.isInit = true
                    return
                }
                if let walkId = obj.getParamValue(key: .id) as? Int{
                    self.walkId = walkId
                    self.dataProvider.requestData(q:.init(id:self.tag,type: .getWalk(walkId: walkId)))
                }
            }
        }//GeometryReader
    }//body
    @State var userId:String = ""
    @State var title:String = String.app.walk
    @State var walkId:Int = -1
    @State var isMe:Bool = false
    @State var mission:Mission? = nil
    @State var topOffSet:CGFloat = Dimen.margin.regular
    @State var imageScale:CGFloat = 1.0
    
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? WalkData else { return }
        self.mission = Mission().setData(data)
        self.updatedData()
    }
    
    private func updatedData(){
        guard let mission = self.mission else {return}
        self.walkId = mission.missionId
        self.userId = mission.user?.snsUser?.snsID ?? self.dataProvider.user.snsUser?.snsID ?? ""
        self.isMe = self.dataProvider.user.isSameUser(userId: self.userId)
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

