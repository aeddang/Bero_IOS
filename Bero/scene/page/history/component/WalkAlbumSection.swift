//
//  AlbumList.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/28.
//

import Foundation
import Foundation
import SwiftUI

struct WalkAlbumSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var title:String? = String.pageTitle.album
    var listSize:CGFloat = 300
    var albums:[WalkPictureItem] = []
    
    var body: some View {
        VStack(spacing:Dimen.margin.regular){
            if let title = self.title {
                TitleTab(type:.section, title: title)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
            }
            VStack(spacing:Dimen.margin.regularExtra){
                if self.albums.isEmpty {
                    EmptyItem(type: .myList)
                } else {
                    ForEach(self.albums) { data in
                        ListDetailItem(
                            imagePath: data.pictureUrl,
                            imgSize: CGSize(width: self.listSize, height: self.listSize)
                        )
                    }
                }
            }
        }
    }
}


