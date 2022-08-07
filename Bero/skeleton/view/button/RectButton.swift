//
//  RectButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct RectButton: View, SelecterbleProtocol{
    var icon:String? = nil
    var text:String? = nil
    var index: Int = 0
    var isSelected: Bool = false
    var color:Color = Color.brand.primary
    var defaultColor:Color = Color.app.grey500
    var bgColor:Color = Color.app.white
    
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                Spacer().modifier(MatchParent())
                VStack(spacing:Dimen.margin.regularUltra){
                    if let icon = self.icon {
                        Image(icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(!self.isSelected ? self.defaultColor : self.bgColor)
                            .frame(width: Dimen.icon.heavy, height: Dimen.icon.heavy)
                    }
                    if let text = self.text {
                        Text(text)
                            .modifier(MediumTextStyle(
                                size: Font.size.light,
                                color: !self.isSelected ? self.defaultColor : self.bgColor))
                    }
                    
                    
                }
            }
            .frame(width:164, height:168)
            .background(self.isSelected ? self.color : self.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.regular))
            .overlay(
                RoundedRectangle(cornerRadius: Dimen.radius.regular)
                    .strokeBorder(
                        self.isSelected ? self.color : Color.app.grey200,
                        lineWidth: Dimen.stroke.light
                    )
            )
        }
    }
}
#if DEBUG
struct RectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            RectButton(
                icon: Asset.icon.male,
                text: "test",
                isSelected: false,
                color: Color.app.grey400
                ){_ in
                
            }
            RectButton(
                icon: Asset.icon.female,
                text: "test",
                isSelected: true,
                color: Color.brand.primary
                ){_ in
                
            }
        }
    }
}
#endif
