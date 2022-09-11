//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct RewardInfo: PageComponent{
    enum ValueType{
        case point, exp
        var icon:String{
            switch self {
            case .point : return Asset.icon.point
            case .exp : return Asset.icon.lightening_circle
            }
        }
        
        var iconColor:Color?{
            switch self {
            case .exp : return Color.brand.primary
            default : return nil
            }
        }
    }
    
    var type:ValueType = .point
    var value:Int
    var body: some View {
        ZStack(){
            HStack( spacing: Dimen.margin.micro){
                Text("+"+value.description)
                    .modifier(BoldTextStyle(
                        size: Font.size.thin, color: Color.app.grey400))
                if let color = self.type.iconColor {
                    Image(self.type.icon)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(color)
                        .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                } else {
                    Image(self.type.icon)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                }
            }
        }
        .frame(width: 75, height: Dimen.button.light)
        .background(Color.app.whiteDeepLight)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
        
    }
}

#if DEBUG
struct RewardInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            RewardInfo(
                type: .point,
                value: 100
            )
            RewardInfo(
                type: .exp,
                value: 100
            )
           
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
