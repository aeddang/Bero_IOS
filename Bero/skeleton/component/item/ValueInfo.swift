//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct ValueInfo: PageComponent{
    enum ValueType{
        case point, coin, heart, walk, mission, walkComplete, walkDistance, lv(Lv),
             missionComplete, exp , expEarned , pointEarned
        var icon:String{
            switch self {
            case .lv(let lv): return lv.icon
            case .exp, .expEarned : return Asset.icon.exp
            case .point, .pointEarned : return Asset.icon.point
            case .coin : return Asset.icon.coin
            case .heart : return Asset.icon.favorite_on
            case .walkComplete : return Asset.icon.paw
            case .walkDistance : return Asset.icon.walk
            case .missionComplete : return Asset.icon.goal
            default : return Asset.image.puppy
            }
        }
        
        var iconColor:Color?{
            switch self {
            case .lv, .exp, .expEarned : return nil
            case .walkDistance : return Color.app.black
            case .coin, .point, .pointEarned, .heart : return nil
            default : return Color.brand.primary
            }
        }
        
        var textColor:Color?{
            switch self {
            case .lv(let lv) : return lv.color
            default : return self.iconColor
            }
        }
        var text:String?{
            switch self {
            case .lv: return "Level"
            case .exp : return "EXP"
            case .point : return "Points"
            case .expEarned : return "EXP earned"
            case .pointEarned : return "Points earned"
            case .coin : return "Coins"
            case .heart : return "Heart Level"
            case .walk : return "from walk"
            case .mission : return "from mission"
            case .walkComplete : return "Walks done"
            case .walkDistance : return "Walk distance"
            case .missionComplete : return "Missions completed"
            }
        }
        
        func getValue(_ value:Double) -> String{
            switch self {
            case .coin : return value.description
            case .walkDistance : return WalkManager.viewDistance(value)
            default : return value.toInt().description
            }
        }
        
        var isIconFirst:Bool{
            switch self {
            case .heart, .lv : return true
            default : return false
            }
        }
    }
    
    var type:ValueType = .point
    var value:Double
    var body: some View {
        VStack(spacing:Dimen.margin.micro){
            HStack( spacing: Dimen.margin.micro){
                if self.type.isIconFirst {
                    if let color = self.type.iconColor {
                        Image(self.type.icon)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor( value == 0 ? Color.app.grey300 : color)
                            .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    } else {
                        switch self.type {
                        case .heart :
                            Image(self.type.icon)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Lv.getLv(self.value.toInt()).color)
                                .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                        default :
                            Image(self.type.icon)
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                        }
                    }
                   
                }
                Text(self.type.getValue(value))
                    .modifier(BoldTextStyle(
                        size: Font.size.medium,color: value == 0 ? Color.app.grey300 : (self.type.textColor ?? Color.brand.primary)))
                if !self.type.isIconFirst {
                    if let color = self.type.iconColor {
                        Image(self.type.icon)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor( value == 0 ? Color.app.grey300 : color)
                            .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    } else {
                        Image(self.type.icon)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    }
                }
            }
            if let text = self.type.text{
                Text(text)
                    .modifier(RegularTextStyle(
                        size: Font.size.tiny, color: Color.app.grey300))
            }
        }
    }
}

#if DEBUG
struct ValueInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            ValueInfo(
                type: .heart,
                value: 100
            )
            ValueInfo(
                type: .point,
                value: 100
            )
            
            ValueInfo(
                type: .coin,
                value: 100
            )
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
