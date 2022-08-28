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
        case point, coin, heart
        var icon:String{
            switch self {
            case .point : return Asset.icon.point
            case .coin : return Asset.icon.coin
            case .heart : return Asset.icon.favorite_on
            }
        }
        
        var text:String?{
            switch self {
            case .point : return "Points"
            case .coin : return "Coins"
            case .heart : return "Heart Level"
            }
        }
        
        func getValue(_ value:Double) -> String{
            switch self {
            case .point : return value.toInt().description
            case .coin : return value.description
            case .heart : return value.toInt().description
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
                    Image(self.type.icon)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.brand.primary)
                        .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
                }
                Text(self.type.getValue(value))
                    .modifier(BoldTextStyle(
                        size: Font.size.medium,color: Color.brand.primary))
                if !self.type.isIconFirst {
                    Image(self.type.icon)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimen.icon.regular, height: Dimen.icon.regular)
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
