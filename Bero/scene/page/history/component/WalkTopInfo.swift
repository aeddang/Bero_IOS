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
    var mission:Mission
    var body: some View {
        HStack(alignment: .bottom, spacing:Dimen.margin.thin){
            VStack(alignment: .leading, spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                if let text = self.mission.title ?? self.mission.type.text {
                    Text(text)
                        .modifier(SemiBoldTextStyle(
                            size: Font.size.medium,
                            color: Color.app.black
                        ))
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
}
