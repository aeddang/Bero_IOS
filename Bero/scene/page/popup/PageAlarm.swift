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

struct PageAlarm: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var repository:Repository
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
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
                        title:String.pageTitle.alarm,
                        useBack:true,
                        buttons: [], //self.isEdit ? [] : [.addAlbum,.setting],
                        action: { type in
                            switch type {
                            case .back :
                                if self.isEdit {
                                    withAnimation{
                                        self.isEdit = false
                                    }
                                } else {
                                    self.pagePresenter.closePopup(self.pageObject?.id)
                                }
                                
                            case .setting :
                                withAnimation{
                                    self.isEdit = true
                                }
                            default : break
                            }
                        }
                    )
                    AlarmList(
                        pageObservable: self.pageObservable,
                        infinityScrollModel: self.infinityScrollModel,
                        isEdit: self.$isEdit
                    )
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onAppear{
                
            }
        }//GeometryReader
    }//body
    @State var isEdit:Bool = false
   
    
}


#if DEBUG
struct PageAlarm_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageAlarm().contentBody
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

