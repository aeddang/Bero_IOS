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

struct PopupWalkUsers: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @ObservedObject var viewPagerModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
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
                        VStack(spacing:0){
                            ImageButton(
                                defaultImage: Asset.icon.drag_handle,
                                size:  CGSize(width: Dimen.icon.medium, height: Dimen.margin.mediumUltra),
                                defaultColor: Color.app.grey100
                            ){ _ in
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                            UsersView(
                                pageObservable:self.pageObservable,
                                navigationModel: self.navigationModel,
                                infinityScrollModel: self.infinityScrollModel
                            )
                            
                        }
                        .onReceive(self.infinityScrollModel.$event){evt in
                            guard let evt = evt else {return}
                            switch evt {
                            case .down, .up :break
                            case .pullCompleted:
                                self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                            case .pullCancel :
                                self.pageDragingModel.uiEvent = .pullCancel(geometry)
                            default : break
                            }
                        }
                        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                            //self.pageDragingModel.uiEvent = .pull(geometry, pos)
                        }
                        /*
                        ImageButton( defaultImage: Asset.icon.close){ _ in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        .padding(.all, Dimen.margin.regular)
                        */
                    }
                    .padding(.bottom, self.appSceneObserver.safeBottomHeight)
                    .modifier(BottomFunctionTab(margin: 0))
                    .padding(.top, Dimen.margin.medium + self.sceneObserver.safeAreaTop)
                    .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    
                }
            }
            .onAppear{
               
            }
            
        }//geo
    }//body
}




 
