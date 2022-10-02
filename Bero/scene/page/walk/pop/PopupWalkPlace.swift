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

struct PopupWalkPlace: PageView {
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
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                switch evt.type {
                case .pageChange :
                    if evt.id == PageID.popupWalkPlace , let place = evt.data as? Place {
                        if let idx = self.walkManager.places.firstIndex(where: {place.placeId == $0.placeId}) {
                            self.viewPagerModel.request = .move(idx)
                        }
                    }
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                let selectPlace = obj.getParamValue(key: .data) as? Place
                var selected:Int = 0
                var idx:Int = 0
                let pages = self.walkManager.places.map{ place in
                    if place.placeId == selectPlace?.placeId{
                        selected = idx
                    }
                    idx += 1
                    return PlaceView(
                        pageObservable:self.pageObservable,
                        pageDragingModel: self.pageDragingModel,
                        infinityScrollModel: self.infinityScrollModel,
                        place:place
                    )
                }
                self.viewPagerModel.index = selected
                self.pages = pages
                
            }
            
        }//geo
    }//body
    @State var pages: [PlaceView] = []
    
    private func move(idx:Int){
        if idx >= self.pages.count {return}
        let page = self.pages[idx]
        guard let loc = page.place.location else {return}
        let modifyLoc = CLLocation(latitude: loc.coordinate.latitude-0.0002, longitude: loc.coordinate.longitude)
        self.walkManager.uiEvent = .moveMap(modifyLoc)
    }
}




 
