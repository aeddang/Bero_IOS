//
//  HeartButton.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/09/03.
//

import Foundation
import SwiftUI

struct HeartButton: View, SelecterbleProtocol{
    enum ButtonType{
        case small, big
        var icon:String{
            switch self {
            case .big : return Asset.icon.favorite_on_big
            case .small : return Asset.icon.favorite_on
            }
        }
        
        var size:CGFloat{
            switch self {
            case .big : return Dimen.profile.heavyExtra
            case .small : return Dimen.icon.mediumUltra
            }
        }
        var textSize:CGFloat{
            switch self {
            case .big : return Font.size.medium
            case .small : return Font.size.tiny
            }
        }
    }
    
    var index: Int = -1
    var type:ButtonType = .small
    var text:String? = nil
    var defaultColor:Color = Color.app.grey100
    var activeColor:Color = Color.brand.primary
    var isSelected: Bool = false
    let action: (_ idx:Int) -> Void
   
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack(){
                Image(self.type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.isSelected ?  self.activeColor : self.defaultColor)
                    .frame(width: self.type.size, height: self.type.size)
                
                    
                if let text = self.text {
                    Text(text)
                        .modifier(SemiBoldTextStyle(
                            size: self.type.textSize,
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
                type: .big,
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




