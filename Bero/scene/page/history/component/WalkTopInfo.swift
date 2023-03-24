//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct WalkTopInfo: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var mission:Mission
    var isMe:Bool = false
    var body: some View {
        HStack(alignment: .bottom, spacing:Dimen.margin.thin){
            VStack(alignment: .leading, spacing:0){
                HStack( spacing: Dimen.margin.tiny){
                    VStack(alignment: .leading, spacing:0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        HStack( spacing: Dimen.margin.tiny){
                            if let day = self.day {
                                Text(day)
                                    .modifier(SemiBoldTextStyle(
                                        size: Font.size.thin,
                                        color: Color.app.black
                                    ))
                                Text("|")
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color: Color.brand.primary
                                    ))
                            }
                            if let time = self.time {
                                Text(time)
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,
                                        color: Color.app.grey400
                                    ))
                                    .padding(.top, Dimen.margin.microExtra)
                            }
                        }
                    }
                    if self.isMe , let picture = self.mission.walkPath?.picture {
                        SortButton(
                            type: .stroke,
                            sizeType: .small,
                            icon: Asset.icon.global,
                            text: String.app.share,
                            color: self.isExpose ? Color.brand.primary : Color.app.grey400,
                            isSort: false
                        ){
                            self.dataProvider.requestData(
                                q: .init( type: .updateAlbumPicture(pictureId: picture.pictureId ?? 0 , isExpose: !self.isExpose)))
                        }
                    }
                }
                
                
                
            }
            
        }
        .onReceive(self.mission.$isExpose){ isExpose in
            self.isExpose = isExpose
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAlbumPicture(let pictureId, _, let isExpose):
                if pictureId == self.mission.walkPath?.picture?.pictureId, let isExpose = isExpose {
                    self.isExpose = isExpose
                    self.mission.isExpose = isExpose
                }
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .updateAlbumPicture(let pictureId, let isLike, let isExpose): self.updated(pictureId, isLike: isLike, isExpose:isExpose)
            default : break
            }
        }
        .onAppear{
            if let start = self.mission.startDate, let end = self.mission.endDate {
                let ymdStart = start.toDateFormatter(dateFormat:"yyyyMM")
                let ymdEnd = end.toDateFormatter(dateFormat:"yyyyMM")
                if ymdStart == ymdEnd {
                    self.day = end.toDateFormatter(dateFormat:"MMMM d, yyyy")
                    self.time = start.toDateFormatter(dateFormat:"HH:mm") + " - " + end.toDateFormatter(dateFormat:"HH:mm")
                } else {
                    self.time = start.toDateFormatter(dateFormat:"MMMM d, yyyy HH:mm") + " - " + end.toDateFormatter(dateFormat:"d, HH:mm")
                }
            }
        }
    }
    @State var day:String? = nil
    @State var time:String? = nil
    @State var isExpose:Bool = false
    
    private func updated(_ id:Int, isLike:Bool?, isExpose:Bool?){
        if self.mission.walkPath?.picture?.pictureId == id {
            if let expose = isExpose {
                self.appSceneObserver.event = .toast(expose ? String.alert.exposed : String.alert.unExposed)
            }
        }
    }
}
