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
                        SwipperScrollView(
                            viewModel: self.viewPagerModel,
                            count: self.pages.count,
                            coordinateSpace: .global
                        ){
                            ForEach(self.pages) { data in
                                PlaceView(
                                    pageObservable:self.pageObservable,
                                    place:data)
                                .frame(width: geometry.size.width)
                            }
                        }
                        /*
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            axes: .horizontal,
                            showIndicators : false,
                            marginTop: 0,
                            marginBottom: 0,
                            marginHorizontal:0,
                            spacing:0,
                            isRecycle: true,
                            useTracking: true
                        ){
                            ForEach(self.pages) { data in
                                PlaceView(
                                    pageObservable:self.pageObservable,
                                    place:data)
                                .frame(width: geometry.size.width)
                                .id(data.hashId)
                            }
                        }
                        */
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
                        self.move(idx: place.index)
                    }
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                let selectPlace = obj.getParamValue(key: .data) as? Place
                //self.pages = self.walkManager.places
                
                let width = geometry.size.width
                self.pages = zip(0..<self.walkManager.places.count, self.walkManager.places).map{ idx , place in
                    let p = place.setRange(idx:idx, width: width) as! Place
                    return p
                }
                 
                if let selected = self.pages.first(where: {$0.placeId == selectPlace?.placeId}){
                    self.viewPagerModel.index = selected.index
                }
            }
            
        }//geo
    }//body
    @State var pages: [Place] = []
   
    private func move(idx:Int){
        if idx >= self.pages.count {return}
        let page = self.pages[idx]
        //DataLog.d("page " + (page.name ?? ""), tag: self.tag)
        //DataLog.d("page " + page.startPos.description, tag: self.tag)
        //self.infinityScrollModel.uiEvent = .scrollMove(page.hashId, .top)
        //if self.currentIdx == idx { return }
        //self.currentIdx = idx
        guard let loc = page.location else {return}
        let modifyLoc = CLLocation(latitude: loc.coordinate.latitude-0.0002, longitude: loc.coordinate.longitude)
        self.walkManager.uiEvent = .moveMap(modifyLoc)
        
    }
}




 
