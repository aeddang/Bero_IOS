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
    var icon:String? = nil
    let title:String
    var value:String = ""
    var color:Color = Color.brand.primary
    var bgColor:Color = Color.app.whiteDeepLight
    var body: some View {
        VStack(spacing:Dimen.margin.micro){
            if let icon = self.icon {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.color)
                    .frame(width:Dimen.icon.light,height: Dimen.icon.light)
            }
            Text(title)
                .modifier(RegularTextStyle(
                    size: Font.size.tiny, color: Color.app.grey400))
            Text(value)
                .modifier(MediumTextStyle(
                    size: Font.size.light, color: Color.app.black))
        }
        .modifier(MatchHorizontal(height: 80))
        .background(self.bgColor)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
    }
}



#if DEBUG
struct PropertyInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        HStack(spacing:Dimen.margin.thin){
            PropertyInfo(
                icon: Asset.icon.speed,
                title: "Weight",
                value: "8.1 kg",
                bgColor: Color.transparent.clear
            )
            PropertyInfo(
                title: "Weight",
                value: "8.1 kg"
            )
            PropertyInfo(
                title: "Weight",
                value: "8.1 kg"
            )
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
