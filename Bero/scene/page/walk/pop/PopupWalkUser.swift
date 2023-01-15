//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import GoogleMaps

struct PopupWalkUser: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @ObservedObject var viewPagerModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                ZStack(alignment: .bottom){
                    Spacer().modifier(MatchParent())
                        .background(Color.transparent.clear)
                    ZStack(alignment: .topTrailing){
                        VStack(spacing:0){
                            ImageButton(
                                defaultImage: Asset.icon.drag_handle,
                                size:  CGSize(width: Dimen.icon.medium, height: Dimen.margin.mediumUltra),
                                defaultColor: Color.app.grey100
                            ){ _ in
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                            if let data = self.current {
                                UserView(
                                    pageObservable:self.pageObservable,
                                    geometry: geometry,
                                    mission: data
                                )
                                .frame(width: geometry.size.width)
                                .padding(.top, Dimen.margin.thin)
                            }
                            /*
                            InfinityScrollView(
                                viewModel: self.infinityScrollModel,
                                axes: .horizontal,
                                showIndicators : false,
                                marginTop: Dimen.margin.micro,
                                marginBottom: 0,
                                marginHorizontal: Dimen.app.pageHorinzontal,
                                spacing:0,
                                isRecycle: true,
                                useTracking: true
                            ){
                                ForEach(self.pages) { data in
                                    Button(action: {
                                        self.move(idx: data.index)
                                    }) {
                                        ProfileImage(
                                            imagePath: data.user?.representativePet?.imagePath,
                                            isSelected: data.index == self.current?.index,
                                            size: Dimen.profile.thin,
                                            emptyImagePath: Asset.image.profile_dog_default
                                        )
                                    }
                                }
                            }
                            */
                        }
                        /*
                        ImageButton( defaultImage: Asset.icon.close, padding: Dimen.margin.tiny){ _ in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        */
                    }
                    .padding(.bottom, self.appSceneObserver.safeBottomHeight)
                    .modifier(BottomFunctionTab(margin: 0))
                    .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                }
                
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                switch evt.type {
                case .pageChange :
                    if evt.id == PageID.popupWalkUser , let mission = evt.data as? Mission {
                        self.move(idx: mission.index)
                    }
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                let selectMission = obj.getParamValue(key: .data) as? Mission
                self.pages = self.walkManager.missionUsers
                self.move(idx: selectMission?.index ?? 0)
                /*
                if let selected = self.pages.first(where: {$0.missionId == selectMission?.missionId}){
                    self.viewPagerModel.index = selected.index
                    self.current = selected
                }*/
            }
            
        }//geo
    }//body
    
    @State var current:Mission? =  nil
    @State var pages:[Mission] = []
    private func move(idx:Int){
        if idx < 0 {return}
        if idx >= self.pages.count {return}
        let page = self.pages[idx]
        if self.current?.missionId == page.missionId { return }
        self.current = page
        guard let loc = page.location else {return}
        let modifyLoc = CLLocation(latitude: loc.coordinate.latitude-0.0002, longitude: loc.coordinate.longitude)
        self.walkManager.uiEvent = .moveMap(modifyLoc)
        
    }
}



 
