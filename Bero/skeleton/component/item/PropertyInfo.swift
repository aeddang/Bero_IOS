//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct PropertyInfo: PageComponent{
    enum BoxType{
        case blank, normal, impect
        var bgColor:Color{
            switch self {
            case .impect : return Color.app.grey50
            case .normal : return Color.app.whiteDeepLight
            case .blank : return Color.transparent.clear
            }
        }
        
        var valueTextStyle:String{
            switch self {
            case .impect : return Font.family.bold
            case .normal : return Font.family.medium
            case .blank : return Font.family.medium
            }
        }
        var valueTextSize:CGFloat{
            switch self {
            case .impect : return Font.size.bold
            case .normal : return Font.size.light
            case .blank : return Font.size.light
            }
        }
        
        var boxHeight:CGFloat{
            switch self {
            case .impect : return 72
            default : return 80
            }
        }
        var spacing:CGFloat{
            switch self {
            case .impect : return 0
            default : return Dimen.margin.micro
            }
        }
    }
    var type:BoxType = .normal
    var icon:String? = nil
    var title:String? = nil
    var value:String = ""
    var unit:String? = nil
    var color:Color = Color.brand.primary
    var body: some View {
        
        VStack(spacing:self.type.spacing){
            if let icon = self.icon {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.color)
                    .frame(width:Dimen.icon.light,height: Dimen.icon.light)
            }
            if let title = self.title {
                Text(title)
                    .modifier(RegularTextStyle(
                        size: Font.size.tiny, color: Color.app.grey400))
            }
            Text(value)
                .modifier(CustomTextStyle(textModifier: .init(
                    family: self.type.valueTextStyle,
                    size: self.type.valueTextSize,
                    color: Color.app.grey400
                )))
            if let unit = self.unit {
                Text(unit)
                    .modifier(
                        RegularTextStyle(
                            size: Font.size.tiny, color: Color.app.grey400))
            }
        }
        .modifier(MatchHorizontal(height: self.type.boxHeight))
        .background(self.type.bgColor)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
    }
}



#if DEBUG
struct PropertyInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        HStack(spacing:Dimen.margin.thin){
            PropertyInfo(
                type: .blank,
                icon: Asset.icon.speed,
                title: "Weight",
                value: "8.1 kg"
            )
            PropertyInfo(
                type: .normal,
                title: "Weight",
                value: "8.1 kg"
            )
            PropertyInfo(
                type: .impect,
                value: "8.1",
                unit:"kg"
            )
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
