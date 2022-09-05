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

struct PageExplore: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
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
                    HStack(spacing: Dimen.margin.thin){
                        TitleTab(
                            title: String.pageTitle.explore,
                            buttons:[]){ type in
                            }
                        SortButton(
                            type: .stroke,
                            sizeType: .big,
                            text: self.type.title,
                            color:Color.app.grey400,
                            isSort: true){
                                self.onSort()
                            }
                            .fixedSize()
                    }
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    Spacer().modifier(LineHorizontal())
                    UserList(
                        infinityScrollModel: self.infinityScrollModel,
                        type: self.$type,
                        listSize: geometry.size.width,
                        marginBottom: Dimen.app.bottom
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
    @State var type:MissionApi.SearchType = .Random
    private func onSort(){
        let datas:[String] = [
            MissionApi.SearchType.Random.text,
            MissionApi.SearchType.Friend.text
        ]
        self.appSceneObserver.radio = .sort( (self.tag, datas), title: String.pageText.exploreSeletReport){ idx in
            guard let idx = idx else {return}
            switch idx {
            case 0 : self.type = .Random
            case 1 : self.type = .Friend
            default: break
            }
            DispatchQueue.main.async {
                self.infinityScrollModel.uiEvent = .reload
            }
            
        }
    }

}


#if DEBUG
struct PageExplore_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageExplore().contentBody
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

