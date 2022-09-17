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
                        type:.section,
                        title: self.title ,
                        alignment: .center,
                        useBack: true){ type in
                        switch type {
                        case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                        default : break
                        }
                    }
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
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
                                height: geometry.size.width + self.topOffSet - Dimen.radius.medium
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
                                        WalkTopInfo(mission: mission)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                        MissionPlayInfo(mission: mission)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                            .padding(.top, Dimen.margin.regularUltra)
                                        WalkPropertySection(mission: mission)
                                            .padding(.horizontal, Dimen.app.pageHorinzontal)
                                            .padding(.top, Dimen.margin.regularUltra)
                                        
                                        Spacer().modifier(LineHorizontal(height: Dimen.line.heavy))
                                            .padding(.vertical, Dimen.margin.medium)
                                        
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
                                        Spacer()
                                            .frame(height: max(-self.topOffSet, 0))
                                    }
                                    
                                } else {
                                    Spacer().modifier(MatchParent())
                                }
                            }
                            .modifier(BottomFunctionTab(margin:0))
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
                self.topOffSet = max(scrollPos, -120)
            }
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .searchMission : self.loaded(res)
                default : break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ isOn in
                if isOn {
                    self.loadMissions()
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let mission = obj.getParamValue(key: .data) as? Mission{
                    self.mission = mission
                    self.missionId = mission.missionId
                    self.pageObservable.isInit = true
                }
                
            }
        }//GeometryReader
    }//body
    @State var title:String = String.app.walk
    @State var missionId:Int = -1
    @State var mission:Mission? = nil
    @State var topOffSet:CGFloat = Dimen.margin.regular
    @State var imageScale:CGFloat = 1.0
    @State var missions:[RewardHistoryListItemData] = []
    
    func loadMissions(){
        self.dataProvider.requestData(q: .init(id: self.tag, type:
                .searchMission(.mission, .Walk, searchValue:self.missionId.description), isOptional: true
        ))
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let datas = res.data as? [MissionData] else { return }
        let end =  datas.count
        self.missions = zip(0...end, datas).map { idx, d in
            return RewardHistoryListItemData().setData(d,  idx: idx)
        }
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

