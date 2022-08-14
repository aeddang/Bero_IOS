//
//  CheckBox.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct RadioButton: View, SelecterbleProtocol {
    enum ButtonType{
        case blank, stroke
        var strokeWidth:CGFloat{
            switch self {
            case .blank : return 0
            case .stroke : return Dimen.stroke.light
            }
        }
        
        var icon:String{
            switch self {
            case .blank : return Asset.icon.check
            case .stroke : return Asset.icon.checked_circle
            }
        }
        
        var iconSize:CGFloat{
            switch self {
            case .blank : return Dimen.icon.light
            case .stroke : return Dimen.icon.medium
            }
        }
        var spacing:CGFloat{
            switch self {
            case .blank : return 0
            case .stroke : return Dimen.margin.tinyExtra
            }
        }
        var bgColor:Color{
            switch self {
            case .blank : return Color.transparent.clearUi
            case .stroke : return Color.app.white
            }
        }
    }
    var type:ButtonType = .stroke
    var isChecked: Bool
    var text:String? = nil
    var color:Color = Color.brand.primary
    var action: (_ check:Bool) -> Void
    var body: some View {
        Button(action: {
            action(!self.isChecked)
        }) {
            HStack(alignment: .center, spacing: 0){
                if self.text != nil {
                    VStack(alignment: .leading, spacing: 0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        Text(self.text!)
                            .modifier( RegularTextStyle(
                                size: Font.size.light,
                                color: self.isChecked ? self.color : Color.app.grey400
                            ))
                    }
                }
                if self.isChecked || self.type != .blank{
                    Image(self.type.icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(self.isChecked ? self.color : Color.app.grey400)
                        .frame(width: self.type.iconSize, height: self.type.iconSize)
                }
            }
            .padding(.horizontal, self.type == .blank ? 0 : Dimen.margin.thin)
            .frame(height: Dimen.button.medium)
            .background(self.type.bgColor)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thinExtra))
            .overlay(
                RoundedRectangle(cornerRadius: Dimen.radius.thinExtra)
                    .strokeBorder(
                        self.isChecked ? self.color : Color.app.grey100,
                        lineWidth: self.type.strokeWidth
                    )
            )
        }
    }
}

#if DEBUG
struct RadioButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            RadioButton(
                type: .blank,
                isChecked: true,
                text:"RadioButton"
            ){ _ in
                
            }
            RadioButton(
                type: .stroke,
                isChecked: true,
                text:"RadioButton"
            ){ _ in
                
            }
            RadioButton(
                type: .stroke,
                isChecked: false,
                text:"RadioButton"
            ){ _ in
                
            }
        }
        .padding(.all, 10)
    }
}
#endif

