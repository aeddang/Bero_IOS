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

struct PopupPlaceVisitor: PageView {
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
                           .background(Color.transparent.black45)
                    }
                    ZStack(alignment: .topTrailing){
                        Spacer().modifier(MatchParent())
                        VisitorView(
                            pageObservable:self.pageObservable,
                            pageDragingModel: self.pageDragingModel,
                            infinityScrollModel: self.infinityScrollModel,
                            totalCount: self.totalCount,
                            datas: self.visitors
                        )
                        ImageButton( defaultImage: Asset.icon.close){ _ in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        .padding(.all, Dimen.margin.regular)
                    }
                    .padding(.bottom, self.appSceneObserver.safeBottomHeight)
                    .modifier(MatchHorizontal(height: 430))
                    .modifier(BottomFunctionTab(margin: 0))
                    .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                guard let place = obj.getParamValue(key: .data) as? Place else { return }
                self.totalCount = place.visitorCount
                self.visitors = place.visitors.map{MultiProfileListItemData().setData($0, idx: -1)}
            }
            
        }//geo
    }//body
    
    @State var totalCount: Int = 0
    @State var visitors: [MultiProfileListItemData] = []
}




 
