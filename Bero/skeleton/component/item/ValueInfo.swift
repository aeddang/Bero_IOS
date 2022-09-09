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
        case point, coin, heart, walk, mission, walkComplete, missionComplete
        var icon:String{
            switch self {
            case .point : return Asset.icon.point
            case .coin : return Asset.icon.coin
            case .heart : return Asset.icon.favorite_on
            case .walkComplete : return Asset.icon.paw
            case .missionComplete : return Asset.icon.goal
            default : return Asset.icon.lightening_circle
            }
        }
        
        var iconColor:Color?{
            switch self {
            case .heart, .walk, .mission : return Color.brand.primary
            case .walkComplete : return  Color.brand.primary
            case .missionComplete : return  Color.brand.secondary
            default : return nil
            }
        }
        var text:String?{
            switch self {
            case .point : return "Points"
            case .coin : return "Coins"
            case .heart : return "Heart Level"
            case .walk : return "from walk"
            case .mission : return "from mission"
            case .walkComplete : return "Walks done"
            case .missionComplete : return "Missions completed"
            }
        }
        
        func getValue(_ value:Double) -> String{
            switch self {
            case .coin : return value.description
            default : return value.toInt().description
            }
        }
        
        var isIconFirst:Bool{
            switch self {
            case .heart : return true
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
                            .foregroundColor(color)
                            .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    } else {
                        Image(self.type.icon)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                    }
                   
                }
                Text(self.type.getValue(value))
                    .modifier(BoldTextStyle(
                        size: Font.size.medium,color: value == 0 ? Color.app.grey400 : Color.brand.primary))
                if !self.type.isIconFirst {
                    if let color = self.type.iconColor {
                        Image(self.type.icon)
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(color)
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
                        size: Font.size.tiny, color: Color.app.grey400))
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
