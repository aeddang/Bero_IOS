//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation
import GooglePlaces
struct PlaceInfo: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    var pageObservable:PageObservable = PageObservable()
    var sortIconPath:String? = nil
    var sortTitle:String? = nil
    var title:String? = nil
    var description:String? = nil
    var distance:Double? = nil
    var goal:CLLocation? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Spacer().modifier(MatchHorizontal(height: 0))
            VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                if self.sortTitle?.isEmpty == false || self.sortIconPath?.isEmpty == false {
                    HStack( spacing: Dimen.margin.tiny){
                        if let path = self.sortIconPath {
                            ImageView(url: path,
                                      contentMode: .fill,
                                      noImg: Asset.noImg1_1)
                            .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                            /*
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.micro))
                            .overlay(
                                RoundedRectangle(cornerRadius: Dimen.radius.micro)
                                    .strokeBorder(
                                        Color.app.orangeSub2,
                                        lineWidth: Dimen.stroke.light
                                    )
                            )*/
                        }
                        if let title = self.sortTitle {
                            Text(title)
                                .modifier(SemiBoldTextStyle(size:Font.size.light, color: Color.brand.primary))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.bottom, Dimen.margin.tiny)
                }
                if let title = self.title {
                    Text(title)
                        .modifier(SemiBoldTextStyle(size:Font.size.medium, color: Color.app.black))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let desc = self.description {
                    Text(desc)
                        .modifier(RegularTextStyle(size:Font.size.thin, color: Color.app.grey400))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let distance = self.distance {
                    HStack( spacing: Dimen.margin.tinyExtra){
                        Image(Asset.icon.walk)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.app.grey300)
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                        Text(WalkManager.viewDistance(distance))
                            .modifier(RegularTextStyle(size:Font.size.thin, color: Color.app.grey300))
                        if let goal = self.goal {
                            ImageButton(
                                defaultImage: Asset.icon.goal,
                                defaultColor: Color.brand.secondary
                            ){ _ in
                                withAnimation{
                                    //self.pageObservable.pageOpacity = 0.5
                                    self.pageObservable.pagePosition = .init(x: 0, y: 200)
                                }
                                self.walkManager.getRoute(goal: goal)
                                DispatchQueue.main.asyncAfter(deadline: .now()+PlayMap.routeViewDuration){
                                    withAnimation{
                                        //self.pageObservable.pageOpacity = 1
                                        self.pageObservable.pagePosition = .zero
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, Dimen.margin.tiny)
                    
                    
                }
            }
        }
    }
}

#if DEBUG
struct PlaceInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlaceInfo(
                sortIconPath: "dhshshh",
                sortTitle: "sort",
                title: "test",
                description: "description",
                distance: 100002
            )
        }
        .padding(.all, 10)
    }
}
#endif
