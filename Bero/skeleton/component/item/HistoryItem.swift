//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct HistoryItem: PageComponent{
    enum HistoryType{
        case point, exp, mission, walk
        var icon:String{
            switch self {
            case .point : return Asset.icon.point
            case .exp : return Asset.icon.exp
            case .walk : return Asset.icon.paw
            case .mission : return Asset.icon.goal

            }
        }
        var apiType:RewardApi.ValueType {
            switch self {
            case .point : return .Point
            case .exp : return .Exp
            default : return .Exp
            }
        }
    }
    let id:String
    var type:HistoryType = .exp
    var title:String? = nil
    var date:String? = nil
    var value:Int = 0
    
    var action: (() -> Void)? = nil
    var body: some View {
        HStack(spacing:Dimen.margin.tinyExtra){
            VStack(alignment: .leading, spacing:0){
                Spacer().modifier(MatchHorizontal(height: 0))
                if let title = self.title {
                    Text(title)
                        .modifier(SemiBoldTextStyle(
                            size: Font.size.light,
                            color: Color.app.black
                        ))
                        .multilineTextAlignment(.leading)
                    
                }
                if let date = self.date {
                    Text(date)
                        .modifier(RegularTextStyle(
                            size: Font.size.tiny,
                            color: Color.app.grey400
                        ))
                }
            }
            Text( "+" + self.value.description)
                .modifier(BoldTextStyle(
                    size: Font.size.medium,
                    color: Color.brand.primary
                ))
                .fixedSize()
            ZStack{
                switch self.type {
                case .point :
                    Image(self.type.icon)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .modifier(MatchParent())
                        
                default :
                    Image(self.type.icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.brand.primary)
                        .modifier(MatchParent())
                        
                }
            }
            .frame(width: Dimen.icon.light, height: Dimen.icon.light)
        }

    }
}


#if DEBUG
struct HistoryItem_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            HistoryItem(
                id: "",
                type: .point,
                title: "name",
                date: "Aug 06 2023",
                value: 99
            )
            HistoryItem(
                id: "",
                type: .exp,
                title: "name",
                date: "Aug 06 2023",
                value: 99
            )
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
