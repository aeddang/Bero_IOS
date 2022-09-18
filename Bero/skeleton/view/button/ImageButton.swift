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
    var iconText:String? = nil
    var text:String? = nil
  
    var defaultColor:Color = Color.app.black
    var activeColor:Color = Color.brand.primary
  
    let action: (_ idx:Int) -> Void
   
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack(alignment: .topTrailing){
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
                .padding(self.iconText == nil ? 0 : Dimen.margin.micro)
                if self.iconText?.isEmpty == false, let text = self.iconText {
                    Text(text)
                        .modifier(MediumTextStyle(
                            size: Font.size.micro,
                            color: Color.app.white
                        ))
                        .frame(width:Dimen.icon.tiny, height: Dimen.icon.tiny)
                        .background(Color.brand.primary)
                        .clipShape(
                            Circle()
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(Color.app.white, lineWidth: Dimen.stroke.light)
                        )
                }
            }
            
            .background(Color.transparent.clearUi)
        }
    }
}

#if DEBUG
struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ImageButton(
                isSelected: false,
                defaultImage:Asset.icon.chat,
                iconText: "N",
                text: "Chat"
            ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
