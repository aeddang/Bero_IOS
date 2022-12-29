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
                    TitleTab(
                        infinityScrollModel: self.infinityScrollModel,
                        title: String.pageTitle.explore,
                        sortButton: self.type.title,
                        sort: self.onSort,
                        buttons:[.add ]){ type in
                            switch type {
                            case .add :
                                self.onPick()
                            default : break
                            }
                        }
                    
                   
                    UserAlbumList(
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
    @State var type:AlbumApi.SearchType = .all
    private func onSort(){
        let datas:[String] = [
            AlbumApi.SearchType.all.text,
            AlbumApi.SearchType.friends.text
        ]
        self.appSceneObserver.radio = .sort( (self.tag, datas), title: String.pageText.exploreSeletReport){ idx in
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
                let scale:CGFloat = 1 //UIScreen.main.scale
                let sizeList = CGSize(
                    width: AlbumApi.thumbSize * scale,
                    height: AlbumApi.thumbSize * scale)
                let thumbImage = pick.normalized().crop(to: sizeList).resize(to: sizeList)
                DispatchQueue.main.async {
                    self.pagePresenter.isLoading = false
                    self.update(img: pick, thumbImage: thumbImage, isExpose:true)
                }
            }
           
        }
    }
    
    private func update(img:UIImage, thumbImage:UIImage, isExpose:Bool){
        guard let id = self.dataProvider.user.snsUser?.snsID else {return}
        self.dataProvider.requestData(q: .init(
            id: id ,
            type: .registAlbumPicture(img: img, thumbImg: thumbImage, id: id, .user, isExpose: isExpose)
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

