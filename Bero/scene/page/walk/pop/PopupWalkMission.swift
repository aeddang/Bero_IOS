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

struct PopupWalkMission: PageView {
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
                    Button(action: {
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }) {
                       Spacer().modifier(MatchParent())
                           .background(Color.transparent.clearUi)
                    }
                    ZStack(alignment: .topTrailing){
                        Spacer().modifier(MatchParent())
                        CPPageViewPager(
                            pageObservable: self.pageObservable,
                            viewModel: self.viewPagerModel,
                            pages: self.pages
                        ){ idx in
                            self.move(idx: idx)
                            
                        }
                        ImageButton( defaultImage: Asset.icon.close){ _ in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        .padding(.all, Dimen.margin.regular)
                    }
                    .padding(.bottom, self.appSceneObserver.safeBottomHeight)
                    .modifier(MatchHorizontal(height: 340))
                    .modifier(BottomFunctionTab(margin: 0))
                    .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                let selectMission = obj.getParamValue(key: .data) as? Mission
                var selected:Int = 0
                var idx:Int = 0
                let pages = self.walkManager.missions.map{ mission in
                    if mission.missionId == selectMission?.missionId{
                        selected = idx
                    }
                    idx += 1
                    return MissionView(
                        pageObservable:self.pageObservable,
                        pageDragingModel: self.pageDragingModel,
                        geometry:geometry,
                        infinityScrollModel: self.infinityScrollModel,
                        mission:mission
                    )
                }
                self.viewPagerModel.index = selected
                self.pages = pages
                
            }
            
        }//geo
    }//body
    @State var pages: [MissionView] = []
    
    private func move(idx:Int){
        if idx >= self.pages.count {return}
        let page = self.pages[idx]
        guard let loc = page.mission.destination else {return}
        let modifyLoc = CLLocation(latitude: loc.coordinate.latitude-0.0002, longitude: loc.coordinate.longitude)
        self.walkManager.uiEvent = .moveMap(modifyLoc)
    }
}




 
