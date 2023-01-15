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
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var mission:Mission
    var isMe:Bool = false
    var body: some View {
        HStack(alignment: .bottom, spacing:Dimen.margin.thin){
            VStack(alignment: .leading, spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                
                if let text = self.mission.title ?? self.mission.type.text {
                    HStack( spacing: Dimen.margin.tiny){
                        Text(text)
                            .modifier(SemiBoldTextStyle(
                                size: Font.size.medium,
                                color: Color.app.black
                            ))
                        if self.isMe , let picture = self.mission.walkPath?.picture {
                            ImageButton(
                                isSelected: self.isExpose,
                                defaultImage: Asset.icon.explore
                            ){ _ in
                                self.dataProvider.requestData(
                                    q: .init( type: .updateAlbumPicture(pictureId: picture.pictureId ?? 0 , isExpose: !self.isExpose)))
                            }
                        }
                    }
                }
                HStack( spacing: Dimen.margin.tiny){
                    if let day = self.day {
                        Text(day)
                            .modifier(RegularTextStyle(
                                size: Font.size.thin,
                                color: Color.app.grey400
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
                    }
                }
                .padding(.top, Dimen.margin.microExtra)
                
            }
            /*
            if self.mission.user?.pets.isEmpty == false , let pets = self.mission.user?.pets.reversed() {
                ZStack(alignment: .trailing){
                    ForEach(pets) { profile in
                        ProfileImage(
                            image:profile.image,
                            imagePath: profile.imagePath,
                            size: Dimen.profile.thin,
                            emptyImagePath: Asset.image.profile_dog_default
                        )
                        .padding(.trailing, Dimen.margin.thin * CGFloat(profile.index))
                    }
                }
                .fixedSize()
            }*/
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
}
