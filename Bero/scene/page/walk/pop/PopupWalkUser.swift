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
                        Spacer().modifier(MatchParent())
                        
                        CPPageViewPager(
                            pageObservable: self.pageObservable,
                            viewModel: self.viewPagerModel,
                            pages: self.pages
                        ){ idx in
                            self.move(idx: idx)
                        }
                        ImageButton( defaultImage: Asset.icon.close, padding: Dimen.margin.tiny){ _ in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                    }
                    .padding(.bottom, self.appSceneObserver.safeBottomHeight)
                    .modifier(MatchHorizontal(height:380))
                    .modifier(BottomFunctionTab(margin: 0))
                    .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
                }
                /*
                .onReceive(self.pageDragingModel.$nestedScrollEvent){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted :
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    case .pull(let pos) :
                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                    default: break
                    }
                }*/
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                switch evt.type {
                case .pageChange :
                    if evt.id == PageID.popupWalkUser , let mission = evt.data as? Mission {
                        if let idx = self.walkManager.missionUsers.firstIndex(where: {mission.missionId == $0.missionId}) {
                            self.viewPagerModel.request = .move(idx)
                        }
                    }
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                let selectMission = obj.getParamValue(key: .data) as? Mission
                var selected:Int = 0
                var idx:Int = 0
                let pages = self.walkManager.missionUsers.map{ mission in
                    let user = mission.user ?? User()
                    if mission.missionId == selectMission?.missionId {
                        selected = idx
                    }
                    idx += 1
                    return UserView(
                        pageObservable:self.pageObservable,
                        pageDragingModel: self.pageDragingModel,
                        geometry: geometry,
                        infinityScrollModel: self.infinityScrollModel,
                        mission: mission
                    )
                }
                self.viewPagerModel.index = selected
                self.pages = pages
                
            }
            
        }//geo
    }//body
    @State var pages:[UserView] = []
    
    private func move(idx:Int){
        if idx >= self.pages.count {return}
        let page = self.pages[idx]
        guard let loc = page.mission.destination else {return}
        let modifyLoc = CLLocation(latitude: loc.coordinate.latitude-0.0002, longitude: loc.coordinate.longitude)
        
        self.walkManager.uiEvent = .moveMap(modifyLoc)
        
    }
}



 
