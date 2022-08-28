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
    let title:String
    var value:String = ""
    var body: some View {
        VStack(spacing:Dimen.margin.micro){
            Text(title)
                .modifier(RegularTextStyle(
                    size: Font.size.tiny, color: Color.app.grey400))
            Text(value)
                .modifier(MediumTextStyle(
                    size: Font.size.light, color: Color.app.black))
        }
        .modifier(MatchHorizontal(height: 80))
        .background(Color.app.whiteDeepLight)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
    }
}

#if DEBUG
struct PropertyInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        HStack(spacing:Dimen.margin.thin){
            PropertyInfo(
                title: "Weight",
                value: "8.1 kg"
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
