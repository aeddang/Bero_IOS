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
        
        var color:Color{
            switch self {
            case .point : return Color.brand.primary
            case .exp : return Color.brand.primary
            }
        }
        var bgcolor:Color{
            switch self {
            case .exp : return Color.app.orangeSub
            case .point : return Color.app.yellowSub
            }
        }
    }
    enum SizeType{
        case small, big
        var textSize:CGFloat{
            switch self {
            case .big : return Font.size.bold
            case .small : return Font.size.thin
            }
        }
        var iconSize:CGFloat{
            switch self {
            case .big : return Dimen.icon.medium
            case .small : return Dimen.icon.thin
            }
        }
        var boxSize:CGSize{
            switch self {
            case .big : return .init(width: 124, height: Dimen.button.regular)
            case .small : return .init(width: 75, height: Dimen.button.light)
            }
        }
        
        var strokeSize:CGFloat{
            switch self {
            case .big : return 0 //Dimen.stroke.light
            case .small : return 0
            }
        }
    }

    var type:ValueType = .point
    var sizeType:SizeType = .small
    var value:Int
    var isActive:Bool = false
    var body: some View {
        ZStack(){
            HStack( spacing: Dimen.margin.tinyExtra){
                Text("+"+value.description)
                    .modifier(SemiBoldTextStyle(
                        size: self.sizeType.textSize, color: self.isActive ? self.type.color : Color.app.grey400))
                if let color = self.type.iconColor {
                    Image(self.type.icon)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(color)
                        .frame(width: self.sizeType.iconSize, height: self.sizeType.iconSize)
                } else {
                    Image(self.type.icon)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: self.sizeType.iconSize, height: self.sizeType.iconSize)
                }
            }
        }
        .frame(width: self.sizeType.boxSize.width, height: self.sizeType.boxSize.height)
        .background(self.isActive ? self.type.bgcolor : Color.app.whiteDeep)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.regular)
                .strokeBorder(
                    Color.brand.primary.opacity(0.15) ,
                    lineWidth: self.sizeType.strokeSize
                )
        )
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
                sizeType: .big,
                value: 100,
                isActive: true
            )
            RewardInfo(
                type: .point,
                sizeType: .big,
                value: 100,
                isActive: true
            )
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
