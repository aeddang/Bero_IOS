//
//  HeartButton.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/09/03.
//

import Foundation
import SwiftUI

struct HeartButton: View, SelecterbleProtocol{
    
    var index: Int = -1
    var text:String? = nil
    var size:CGFloat =  Dimen.icon.mediumUltra
    var defaultColor:Color = Color.app.grey100
    var activeColor:Color = Color.brand.primary
    var isSelected: Bool = false
    let action: (_ idx:Int) -> Void
   
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack(){
                Image(Asset.icon.favorite_on)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.isSelected ?  self.activeColor : self.defaultColor)
                    .frame(width: size, height: size)
                
                    
                if let text = self.text {
                    Text(text)
                        .modifier(MediumTextStyle(
                            size: Font.size.tiny,
                            color: Color.app.white
                        ))
                }
            }
        }
    }
}

#if DEBUG
struct HeartButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack{
            HeartButton(
                text: "99",
                isSelected: true
            ){_ in
                
            }
            HeartButton(
                text: "1",
                isSelected: false
            ){_ in
                
            }
        }
    }
}
#endif




