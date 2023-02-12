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
                        Spacer().modifier(MatchHorizontal(height: 0))
                        if let data = self.current {
                            PlaceView(
                                pageObservable:self.pageObservable,
                                place:data
                            )
                            .frame(width: geometry.size.width)
                            .padding(.top, Dimen.margin.regular)
                        }
                        ImageButton( defaultImage: Asset.icon.close){ _ in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        .padding(.all, Dimen.margin.regular)
                    }
                    .padding(.bottom, self.appSceneObserver.safeBottomHeight + self.marginBottom)
                    .modifier(BottomFunctionTab(margin: 0))
                    .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                }
            }
            .onReceive(self.walkManager.$isSimpleView){ isSimpleView in
                withAnimation{
                    self.marginBottom = isSimpleView ? Dimen.margin.mediumUltra : 0
                }
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                switch evt.type {
                case .pageChange :
                    if evt.id == PageID.popupWalkPlace , let place = evt.data as? Place {
                        self.current = nil
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                            self.move(idx: place.index)
                        }
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
                self.move(idx: selectPlace?.index ?? 0)
                /*
                if let selected = self.pages.first(where: {$0.placeId == selectPlace?.placeId}){
                    self.viewPagerModel.index = selected.index
                    self.current = selected
                }*/
            }
            
        }//geo
    }//body
    
    @State var current:Place? =  nil
    @State var pages: [Place] = []
    @State var marginBottom:CGFloat = 0
    private func move(idx:Int){
        if idx < 0 {return}
        if idx >= self.pages.count {return}
        let page = self.pages[idx]
        if self.current?.placeId == page.placeId { return }
        withAnimation{ self.current = page }
        guard let loc = page.location else {return}
        let modifyLoc = CLLocation(latitude: loc.coordinate.latitude-0.0003, longitude: loc.coordinate.longitude)
        self.walkManager.uiEvent = .moveMap(modifyLoc)
        
    }
}




 
