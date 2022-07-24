//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct FillButton: View, SelecterbleProtocol{
    enum ButtonType{
        case fill, stroke
        var strokeWidth:CGFloat{
            switch self {
            case .fill : return 0
            case .stroke : return Dimen.stroke.light
            }
        }
        
        func bgColor(_ color:Color) ->Color{
            switch self {
            case .fill : return color
            case .stroke : return Color.app.white
            }
        }
        
        func textColor(_ color:Color) ->Color{
            switch self {
            case .fill : return Color.app.white
            case .stroke : return color
            }
        }
    }
    var type:ButtonType = .fill
    var icon:String? = nil
    var text:String = ""
    var index: Int = 0
    var isActive: Bool = false
    
    var size:CGFloat = Dimen.button.mediumExtra
    var color:Color = Color.app.black
    var textColor:Color? = nil
    var gradient:Gradient? = nil
    var textSize:CGFloat = Font.size.light
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            ZStack{
                if let gradient = self.gradient {
                    LinearGradient(
                        gradient:gradient,
                        startPoint: .leading, endPoint: .trailing)
                        .modifier(MatchParent())
                }
                HStack(spacing:Dimen.margin.tinyExtra){
                    if let icon = self.icon {
                        switch self.type  {
                        case .fill :
                            Image(icon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.white)
                                .frame(width:Dimen.icon.light, height:Dimen.icon.light)
                        case .stroke :
                            Image(icon)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width:Dimen.icon.light, height:Dimen.icon.light)
                        }
                        
                    }
                    Text(self.text)
                        .modifier(SemiBoldTextStyle(size: self.textSize,
                                                    color: self.textColor ?? self.type.textColor(self.color)))
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
            }
            .modifier( MatchHorizontal(height: self.size) )
            .background(self.type.bgColor(self.color))
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
            .overlay(
                RoundedRectangle(cornerRadius: Dimen.radius.thin)
                    .strokeBorder(
                        self.type.textColor(self.color),
                        lineWidth: self.type.strokeWidth
                    )
            )
        }
    }
}
#if DEBUG
struct FillButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            FillButton(
                type: .fill,
                text: "fill buttom"
            ){_ in
                
            }
            FillButton(
                type: .stroke,
                text: "stroke button"
                
            ){_ in
                
            }
            FillButton(
                type: .fill,
                text: "gradient buttom",
                gradient: Color.app.orangeGradient
            ){_ in
                
            }
            .modifier(Shadow())
        }
        .padding(.all, 10)
    }
}
#endif

