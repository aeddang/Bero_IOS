//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI




struct ChangeBox: PageComponent{
    var prev:String? = nil
    var next:String? = nil
    var color:Color = Color.app.white
    var activeColor:Color = Color.brand.primary
    var body: some View {
        HStack(spacing:Dimen.margin.regularExtra){
            if let prev = self.prev {
                Text(prev)
                    .modifier(BoldTextStyle(
                        size: Font.size.medium,
                        color: self.color
                    ))
            }
            
            Image(Asset.icon.arrow_right)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(self.color)
                .frame(width: Dimen.icon.light, height: Dimen.icon.light)
            
            if let next = self.next {
                Text(next)
                    .modifier(BoldTextStyle(
                        size: Font.size.bold,
                        color: self.activeColor
                    ))
            }
        }
        .padding(.vertical, Dimen.margin.light)
        .padding(.horizontal, Dimen.margin.medium)
        .frame(height: Dimen.button.medium)
        .background(Color.transparent.clearUi)
        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.mediumUltra))
        .overlay(
            RoundedRectangle(cornerRadius: Dimen.radius.mediumUltra)
                .strokeBorder(
                    self.color,
                    lineWidth: Dimen.stroke.light
                )
        )
        
    }
}


#if DEBUG
struct ChangeBox_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            ChangeBox(
                prev: "Lv.1",
                next: "Lv.2"
            )
        }
        .padding(.all, 10)
        .background(Color.transparent.black70)
    }
}
#endif
