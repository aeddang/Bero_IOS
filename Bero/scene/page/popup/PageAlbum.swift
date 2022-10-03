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

struct PageAlbum: PageView {
    enum ViewType{
        case info, album
    }
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    let buttons = [String.button.information, String.button.album]
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
                        title:String.button.album,
                        useBack:true,
                        buttons: self.user?.isMe == true ? [.setting] : []){ type in
                        switch type {
                        case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                        case .setting :
                            withAnimation{
                                self.isEdit.toggle()
                            }
                        default : break
                        }
                    }
                    if let user = self.user {
                        AlbumList(
                            pageObservable: self.pageObservable,
                            infinityScrollModel: self.infinityScrollModel,
                            type:.detail,
                            user:user,
                            listSize: geometry.size.width,
                            isEdit: self.$isEdit
                        )
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let user = obj.getParamValue(key: .data) as? User{
                    self.user = user
                    return
                }
            }
        }//GeometryReader
    }//body
    @State var user:User? = nil
    @State var isEdit:Bool = false
}


#if DEBUG
struct PageAlbum_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageAlbum().contentBody
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

