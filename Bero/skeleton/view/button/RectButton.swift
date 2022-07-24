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
    let text:String
    var index: Int = 0
    var isSelected: Bool = false
    var textModifier:TextModifier = TextModifier(
        family:Font.family.regular,
        size:Font.size.light,
        color: Color.app.white,
        activeColor: Color.app.white
    )
    var bgColor = Color.app.black
    var bgActiveColor = Color.brand.primary
    var fixSize:CGFloat? = nil
    
    var icon:String? = nil
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                if let size = self.fixSize  {
                    Spacer().frame( width: size )
                }
                HStack(spacing:Dimen.margin.tiny){
                    Text(self.text)
                        .font(.custom(textModifier.family, size: textModifier.size))
                        .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    
                    
                    if self.icon != nil {
                        Image(self.icon!)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
                    }
                }
                    
            }
            .padding(.horizontal, Dimen.margin.thin)
            .frame(height:Dimen.button.light)
            .background(self.isSelected ? self.bgActiveColor : self.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.medium))
            
        }
    }
}
#if DEBUG
struct RectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RectButton(
                text: "test",
                fixSize: 100
                ){_ in
                
            }
        }
    }
}
#endif
