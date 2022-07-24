//
//  ListStyle.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/05/23.
//

import Foundation
import SwiftUI

struct ListRowInset: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var marginHorizontal:CGFloat = 0
    var spacing:CGFloat = Dimen.margin.thin
    var marginTop:CGFloat = 0
    var bgColor:Color = Color.brand.bg
    
    func body(content: Content) -> some View {
        return content
            .padding(
                .init(
                    top: (index == firstIndex) ? marginTop : 0,
                    leading:  marginHorizontal,
                    bottom: spacing,
                    trailing: marginHorizontal)
            )
            .listRowInsets(
                .init(
                    )
            )
            .listRowBackground(bgColor)
        
    }
}

struct HolizentalListRowInset: ViewModifier {
    var firstIndex = 1
    var index:Int = -1
    var marginVertical:CGFloat = 0
    var spacing:CGFloat = Dimen.margin.thin
    var marginTop:CGFloat = 0
    var bgColor:Color = Color.brand.bg
    
    func body(content: Content) -> some View {
        return content
            .padding(
                EdgeInsets(
                    top: marginVertical,
                    leading:  (index == firstIndex) ? marginTop : 0,
                    bottom: marginVertical,
                    trailing: spacing)
            )
            .listRowInsets(
                EdgeInsets(
                    top: 0, leading: 0, bottom: 0, trailing: 0
                )
            )

            .listRowBackground(bgColor)
        
    }
}
