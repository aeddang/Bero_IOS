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
import struct Kingfisher.KFImage
struct PagePictureViewer: PageView {
    
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var repository:Repository
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack{
                    if let path = self.imagePath {
                        KFImage(URL(string: path))
                            .resizable()
                            .placeholder {
                                Image(Asset.noImg1_1)
                                    .resizable()
                                    .scaledToFit()
                            }
                            .cancelOnDisappear(true)
                            .aspectRatio(contentMode: .fit)
                            .modifier(MatchParent())
                    }
                
                    VStack(alignment: .leading, spacing: 0 ){
                        
                        ImageButton(
                            defaultImage: Asset.icon.back,
                            defaultColor: Color.app.white
                        ){ _ in
                            self.pagePresenter.closePopup(self.pageObject?.id)
                        }
                        
                        Spacer().modifier(MatchParent())
                        if let user = self.user {
                            UserProfileItem(
                                data: user.currentProfile,
                                type: .pet,
                                title: user.representativeName,
                                lv: user.lv,
                                imagePath: user.representativeImage,
                                action:{
                                    self.moveUser(user: user)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    .padding(.top, self.appSceneObserver.safeHeaderHeight + Dimen.margin.regular)
                    .padding(.bottom, self.appSceneObserver.safeBottomHeight)
                }
                .modifier(MatchParent())
                .background(Color.app.black)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onAppear{
               
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .title) as? String{
                    self.title = data
                }
                
                if let data = obj.getParamValue(key: .userData) as? User{
                    self.user = data
                }
                
                if let data = obj.getParamValue(key: .data) as? AlbumListItemData{
                    self.imagePath = data.imagePath
                }
                
                if let data = obj.getParamValue(key: .data) as? String{
                    self.imagePath = data
                }
            }
        }//GeometryReader
    }//body
    @State var title:String? = nil
    @State var user:User? = nil
    @State var imagePath:String? = nil
    
    private func moveUser(user:User){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.user)
                .addParam(key: .data, value: user)
        )
    }
}



