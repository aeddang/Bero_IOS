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

struct PagePicture: PageView {
    
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
                        title:self.title,
                        useBack:true,
                        action:{ type in
                            switch type {
                            case .back :
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        }
                    )
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .vertical,
                        showIndicators : false,
                        marginTop: Dimen.margin.regularUltra,
                        marginBottom: Dimen.margin.medium,
                        marginHorizontal: 0,
                        spacing:Dimen.margin.regularUltra,
                        isRecycle: true,
                        useTracking: true
                    ){
                        ForEach(self.datas) { data in
                            AlbumListDetailItem(data:data, user:self.user,
                                                imgSize: self.itemSize,
                                                isEdit: .constant(false))
                        }
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onAppear{
                self.itemSize = .init(width: self.pageSceneObserver.screenSize.width, height: self.pageSceneObserver.screenSize.width)
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .title) as? String{
                    self.title = data
                }
                if let data = obj.getParamValue(key: .subData) as? User{
                    self.user = data
                }
                if let data = obj.getParamValue(key: .data) as? AlbumListItemData{
                    self.datas = [data]
                }
                if let datas = obj.getParamValue(key: .datas) as? [AlbumListItemData]{
                    self.datas = datas
                }
                
            }
        }//GeometryReader
    }//body
    @State var title:String? = nil
    @State var user:User? = nil
    @State var datas:[AlbumListItemData] = []
    @State var itemSize:CGSize = .zero
}


#if DEBUG
struct PagePicture_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePicture().contentBody
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

