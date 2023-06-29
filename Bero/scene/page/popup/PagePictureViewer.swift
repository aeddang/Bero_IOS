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
                        HStack(spacing: Dimen.margin.thin){
                            ImageButton(
                                defaultImage: Asset.icon.back,
                                defaultColor: Color.app.white
                            ){ _ in
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                            .fixedSize()
                            Spacer().modifier(MatchHorizontal(height: 0))
                            if let isLike = self.isLike {
                                LikeButton(
                                    isLike: isLike,
                                    likeCount: self.likeCount
                                ){
                                    self.like()
                                }
                                .fixedSize()
                            }
                        }
                        Spacer().modifier(MatchParent())
                        HStack(spacing: Dimen.margin.thin){
                            Spacer().modifier(MatchHorizontal(height: 0))
                            if let isExpose = self.isExpose {
                                SortButton(
                                    type: .stroke,
                                    sizeType: .big,
                                    icon: Asset.icon.global,
                                    text: String.app.share,
                                    color: isExpose ? Color.brand.primary : Color.app.grey400,
                                    isSort: false
                                ){
                                    self.share()
                                }
                                .fixedSize()
                            }
                        }
                        /*
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
                        */
                    }
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                    .padding(.top, self.appSceneObserver.safeHeaderHeight + Dimen.margin.regular)
                    .padding(.bottom, self.appSceneObserver.safeBottomHeight)
                    .opacity(self.isShowUi ? 1 : 0)
                }
                .modifier(MatchParent())
                .background(Color.app.black)
                .onTapGesture {
                    withAnimation{
                        self.isShowUi.toggle()
                    }
                }
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                switch res.type {
                case .updateAlbumPicture(let pictureId, let isLike, let isExpose): self.updated(pictureId, isLike: isLike, isExpose:isExpose)
                default : break
                }
            }
            .onAppear{
               
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .title) as? String{
                    self.title = data
                }
                
                if let data = obj.getParamValue(key: .userData) as? User{
                    self.user = data
                }
                
                if let data = obj.getParamValue(key: .data) as? AlbumListItemData{
                    self.data = data
                    self.imagePath = data.imagePath
                    self.updated()
                }
                
                if let data = obj.getParamValue(key: .data) as? String{
                    self.imagePath = data
                }
                
            }
        }//GeometryReader
    }//body
    @State var title:String? = nil
    @State var isMe:Bool = false
    @State var user:User? = nil
    @State var imagePath:String? = nil
    
    @State var data:AlbumListItemData? = nil
  
    @State var likeCount:Double? = nil
    @State var isLike:Bool? = nil
    @State var isExpose:Bool? = nil
    @State var isShowUi:Bool = true
    
    private func moveUser(user:User){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.user)
                .addParam(key: .data, value: user)
        )
    }
    
    private func updated(_ id:Int, isLike:Bool?, isExpose:Bool?){
        if self.data?.pictureId == id {
            self.data?.updata(isLike: isLike, isExpose: isExpose)
            self.updated()
        }
    }
    
    private func updated(){
        self.isLike = self.data?.isLike
        self.likeCount = self.data?.likeCount
        if self.user?.isMe == true {
            self.isExpose = self.data?.isExpose
        }
    }
    
    private func like(){
        guard let id = self.data?.pictureId else {return}
        guard let isLike = self.isLike else {return}
        self.dataProvider.requestData(
            q: .init( type: .updateAlbumPicture(pictureId: id , isLike: !isLike)))
    }
    private func share(){
        guard let id = self.data?.pictureId else {return}
        guard let isExpose = self.isExpose else {return}
        self.dataProvider.requestData(
            q: .init( type: .updateAlbumPicture(pictureId: id , isExpose: !isExpose)))
    }
}



