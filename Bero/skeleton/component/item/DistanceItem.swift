//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit
struct DistanceItem: View, SelecterbleProtocol{
    enum ButtonType{
        case mission, walk
        var icon:String{
            switch self {
            case .mission : return Asset.icon.goal
            case .walk : return Asset.icon.paw
            }
        }
    }
    var type:ButtonType = .walk
    var distance:Double = 0
    var text:String
    var description:String? = nil
    let action: () -> Void
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HStack(spacing:Dimen.margin.light){
                VStack(alignment: .leading, spacing: 0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    HStack(spacing:Dimen.margin.micro){
                        if let icon = self.type.icon {
                            Image(icon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.brand.primary)
                                .frame(width:Dimen.icon.light, height:Dimen.icon.light)
                                
                        }
                        Text(WalkManager.viewDistance(distance))
                            .modifier(MediumTextStyle(
                                size: Font.size.light,
                                color: Color.app.white))
                        
                    }
                }
                .padding(.horizontal, Dimen.margin.tiny)
                .frame(width: 106, height: 40)
                .background(Color.app.black)
                .clipShape(RoundedRectangle(cornerRadius:Dimen.radius.tiny))
                
                VStack(alignment:.leading, spacing:0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    Text(self.text)
                        .modifier(MediumTextStyle(
                            size: Font.size.light,
                            color: Color.app.black))
                    
                    if let tip = self.description {
                        Text(tip)
                            .modifier(MediumTextStyle(
                                size: Font.size.thin,
                                color: Color.app.grey400))
                    }
                    
                }
                Image(Asset.icon.direction_right)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.app.black)
                    .frame(width:Dimen.icon.light, height:Dimen.icon.light)
                
            }
            .padding(.horizontal, Dimen.margin.light)
            .modifier( MatchHorizontal(height: Dimen.tab.heavy) )
            .background(Color.app.white)
            .clipShape(RoundedRectangle(cornerRadius:Dimen.radius.thin))
            .overlay(
                RoundedRectangle(cornerRadius: Dimen.radius.thin)
                    .strokeBorder(
                        Color.app.grey100,
                        lineWidth: Dimen.stroke.light
                    )
            )
            .modifier(ShadowLight())
        }
        
        
    }
}
#if DEBUG
struct DistanceItem_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            DistanceItem(
                type: .walk,
                distance: 1024,
                text: "Walk History",
                description: "56 completed"
            ){
                
            }
            DistanceItem(
                type: .mission,
                distance: 100,
                text: "Mission History",
                description: "Bino Dog Cafe, NY"
            ){
                
            }
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif

