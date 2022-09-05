//
//  CircleButton.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct CircleButton: View, SelecterbleProtocol {
    enum ButtonType{
        case tiny, icon(String), text(String), image(String?, size:CGFloat? = nil)
        var size:CGFloat{
            switch self {
            case .tiny : return Dimen.icon.micro
            case .image(_, let size) : return  size ?? Dimen.icon.mediumUltra
            default : return Dimen.icon.mediumUltra
            }
        }
    }
    var type:ButtonType = .tiny
    var isSelected: Bool = false
    var index:Int = 0
    var icon:String? = nil
    var strokeWidth:CGFloat = 0
    var defaultColor:Color = Color.app.grey300
    var activeColor:Color = Color.brand.primary
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action( self.index )
        }) {
            ZStack{
                switch self.type {
                case .tiny : Spacer().modifier(MatchParent())
                case .icon(let path) :
                    Image(path)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(self.isSelected ? Color.app.white : self.defaultColor)
                        .frame(width: Dimen.icon.light, height: Dimen.icon.light)
                case .text(let title) :
                    Text(title)
                        .modifier(MediumTextStyle(
                            size: Font.size.tiny,
                            color: self.isSelected ? Color.app.white : self.defaultColor
                        ))
                
                 case .image(let path, _):
                    ProfileImage(
                        id : "",
                        imagePath: path,
                        size: self.type.size
                    )
                }
            }
            .frame(width: self.type.size, height: self.type.size)
            .background(self.isSelected ?  self.activeColor : Color.app.white)
            .clipShape(
                Circle()
            )
            .overlay(
                Circle()
                    .strokeBorder(
                        self.isSelected ? Color.app.white : Color.app.grey200,
                        lineWidth: self.strokeWidth
                    )
            )
        }
    }
}

#if DEBUG
struct CircleButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            CircleButton(
                type: .icon(Asset.icon.add_friend),
            isSelected: true,
            strokeWidth: 2){_ in
                
            }
            
            CircleButton(
                type: .tiny,
            isSelected: true,
            strokeWidth: 0){_ in
                
            }
            
            CircleButton(
                type: .text("Lv99"),
            isSelected: true,
            strokeWidth: 2){_ in
                
            }
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
