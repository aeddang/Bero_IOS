//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import GoogleMaps

struct VisitorView: PageComponent, Identifiable{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    let id:String = UUID().uuidString
    var totalCount:Int = 0
    var datas:[MultiProfileListItemData] = []
    var body: some View {
        InfinityScrollView(
            viewModel: self.infinityScrollModel,
            axes: .vertical,
            scrollType: .vertical(isDragEnd: false),
            showIndicators : false,
            marginVertical: Dimen.margin.medium,
            marginHorizontal: Dimen.app.pageHorinzontal,
            spacing:Dimen.margin.regularExtra,
            isRecycle: false,
            useTracking: true
        ){
            Text(String.pageText.walkVisitorTitle.replace(self.totalCount.description))
                .modifier(BoldTextStyle(
                    size: Font.size.regular,
                    color: Color.app.black
                ))
            ForEach(self.datas) { data in
                MultiProfileListItem(data: data)
            }
        }
        .background(Color.app.white)
        .modifier(
            ContentScrollPull(
                infinityScrollModel: self.infinityScrollModel,
                pageDragingModel: self.pageDragingModel)
        )
        
    }
}



#if DEBUG
struct VisitorView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            VisitorView(
                totalCount: 100,
                datas: []
            )
        }
        .padding(.all, 10)
        .background(Color.app.white)
        .environmentObject(PagePresenter())
        .environmentObject(PageSceneObserver())
        .environmentObject(Repository())
        .environmentObject(DataProvider())
        .environmentObject(AppSceneObserver())
    }
}
#endif
