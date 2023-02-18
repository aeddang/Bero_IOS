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
    @State var reloadDegree:Double = 0
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
                        title: String.pageTitle.explore,
                        sortButton: self.type.title,
                        sort: self.onSort,
                        buttons:[.addAlbum ]){ type in
                            switch type {
                            case .addAlbum :
                                self.onPick()
                            default : break
                            }
                        }
                    
                    ZStack(alignment: .top){
                        UserAlbumList(
                            infinityScrollModel: self.infinityScrollModel,
                            type: self.$type,
                            listSize: geometry.size.width,
                            marginBottom: Dimen.app.bottom
                        )
                        ReflashSpinner(
                            progress: self.reloadDegree
                        )
                    }
                }
                .modifier(PageVertical())
                .modifier(MatchParent())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }//draging
            .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                if pos < InfinityScrollModel.PULL_RANGE { return }
                self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
            }
            .onReceive(self.infinityScrollModel.$event){evt in
                  guard let evt = evt else {return}
                  switch evt {
                  case .pullCompleted :
                    self.infinityScrollModel.uiEvent = .reload
                    withAnimation{
                            self.reloadDegree = 0
                        }
                  case .pullCancel :
                    withAnimation{
                        self.reloadDegree = 0
                    }
                  default : break
                  }
            }
            .onAppear{
               
            }
        }//GeometryReader
    }//body
    @State var type:AlbumApi.SearchType = .all
    private func onSort(){
        let icons:[String?] = [
            Asset.icon.global,
            Asset.icon.human_friends
        ]
        let datas:[String] = [
            AlbumApi.SearchType.all.text,
            AlbumApi.SearchType.friends.text
        ]
        self.appSceneObserver.radio = .select(
            (self.tag, icons, datas),
            title: String.pageText.exploreSeletReport,
            selected: self.type == .all ? 0 : 1
        )
        { idx in
            guard let idx = idx else {return}
            switch idx {
            case 0 : self.type = .all
            case 1 : self.type = .friends
            default: break
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                self.infinityScrollModel.uiEvent = .reload
            }
            
        }
    }
    
    
    private func onPick(){
        self.appSceneObserver.select = .imgPicker(self.tag){ pick in
            guard let pick = pick else {return}
            DispatchQueue.global(qos:.background).async {
                let hei = AlbumApi.originSize * CGFloat(pick.cgImage?.height ?? 1) / CGFloat(pick.cgImage?.width ?? 1)
                let size = CGSize(
                    width: AlbumApi.originSize,
                    height: hei)
                let image = pick.normalized().crop(to: size).resize(to: size)
                let sizeList = CGSize(
                    width: AlbumApi.thumbSize,
                    height: AlbumApi.thumbSize)
                let thumbImage = pick.normalized().crop(to: sizeList).resize(to: sizeList)
                DispatchQueue.main.async {
                    self.pagePresenter.isLoading = false
                    self.update(img: image, thumbImage: thumbImage, isExpose:true)
                }
            }
           
        }
    }
    
    private func update(img:UIImage, thumbImage:UIImage, isExpose:Bool){
        guard let id = self.dataProvider.user.snsUser?.snsID else {return}
        self.dataProvider.requestData(q: .init(
            id: id ,
            type: .registAlbumPicture(img: img, thumbImg: thumbImage, userId: id, .user, isExpose: isExpose)
        ))
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

