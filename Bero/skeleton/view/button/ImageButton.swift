//
//  ImageButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

struct ImageButton: View, SelecterbleProtocol{
    var isSelected: Bool = false
    var index: Int = -1
    var defaultImage:String = Asset.noImg1_1
    var activeImage:String? = nil
    var size:CGSize = CGSize(width: Dimen.icon.light, height: Dimen.icon.light)
    var text:String? = nil
  
    var defaultColor:Color = Color.app.black
    var activeColor:Color = Color.brand.primary
    let action: (_ idx:Int) -> Void
   
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            VStack(spacing:Dimen.margin.micro){
                Image(self.isSelected
                        ? (self.activeImage ?? self.defaultImage)
                        : self.defaultImage)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(self.isSelected ?  self.activeColor : self.defaultColor)
                    .frame(width: size.width, height: size.height)
                    
                if let text = self.text {
                    Text(text)
                        .modifier(RegularTextStyle(
                            size: Font.size.tiny,
                            color: self.isSelected ?  self.activeColor : self.defaultColor
                        ))
                }
            }
        }
    }
}

#if DEBUG
struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            ImageButton(
                isSelected: false,
                defaultImage:Asset.icon.close,
                text: "ImageButton"
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
