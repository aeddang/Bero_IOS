//
//  CheckBox.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseAnalytics
struct RadioButton: View, SelecterbleProtocol, PageProtocol {
    enum ButtonType{
        case text, blank, stroke, switchOn, checkOn
        var strokeWidth:CGFloat{
            switch self {
            case .stroke : return Dimen.stroke.light
            default : return 0
            }
        }
        
        var icon:String?{
            switch self {
            case .blank : return Asset.icon.check
            case .stroke, .checkOn : return Asset.icon.checked_circle
            default: return nil
            }
        }
        
        var useFill:Bool{
            switch self {
            case .checkOn : return false
            default: return true
            }
        }
        
        var iconSize:CGFloat{
            switch self {
            case .blank : return Dimen.icon.light
            case .stroke, .checkOn : return Dimen.icon.medium
            default: return 0
            }
        }
        var spacing:CGFloat{
            switch self {
            case .stroke : return Dimen.margin.tinyExtra
            default: return 0
            }
        }
        var horizontalMargin:CGFloat{
            switch self {
            case .stroke : return Dimen.margin.thin
            default: return 0
            }
        }
        var bgColor:Color{
            switch self {
            case .stroke : return Color.app.white
            default: return Color.transparent.clearUi
            }
        }
        var iconColor:Color{
            switch self {
            case .text : return Color.app.black
            default: return Color.app.grey200
            }
        }
        var textColor:Color{
            switch self {
            case .text : return Color.app.black
            default: return Color.app.grey400
            }
        }
        
    }
    var type:ButtonType = .stroke
    var isChecked: Bool
    var icon:String? = nil
    var text:String? = nil
    var description:String? = nil
    var color:Color = Color.brand.primary
    var action: (_ check:Bool) -> Void
    var body: some View {
        Button(action: {
            action(!self.isChecked)
            let parameters = [
                "buttonType": self.tag,
                "buttonText": text ?? icon ?? "",
                "isChecked" : isChecked.description
            ]
            Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
        }) {
            HStack(alignment: self.description==nil ? .center : .top, spacing: Dimen.margin.thin){
                if let icon = self.icon {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(self.isChecked ? self.color : self.type.iconColor)
                        .frame(width:Dimen.icon.light, height:Dimen.icon.light)
                }
                if self.text != nil {
                    VStack(alignment: .leading, spacing: 0){
                        if self.type.useFill {
                            Spacer().modifier(MatchHorizontal(height: 0))
                        }
                        Text(self.text!)
                            .modifier( RegularTextStyle(
                                size: Font.size.light,
                                color: self.isChecked ? self.color : self.type.textColor
                            ))
                            .fixedSize()
                            .multilineTextAlignment(.leading)
                        if let description = self.description {
                            Text(description)
                                .modifier( RegularTextStyle(
                                    size: Font.size.tiny,
                                    color: Color.app.grey400
                                ))
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .padding(.top, Dimen.margin.micro)
                        }
                        
                    }
                }
                switch self.type {
                case .switchOn :
                    Switch(isOn: self.isChecked){ isOn in
                        action(!self.isChecked)
                    }
                default :
                    if self.isChecked || self.type != .blank, let icon = self.type.icon{
                        Image(icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(self.isChecked ? self.color : self.type.iconColor)
                            .frame(width: self.type.iconSize, height: self.type.iconSize)
                    }
                }
                if !self.type.useFill {
                    Spacer().modifier(MatchHorizontal(height: 0))
                }
                
            }
            .padding(.horizontal, self.type.horizontalMargin)
            .padding(.vertical, Dimen.margin.thin)
            //.frame(height: Dimen.button.medium)
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
                type: .checkOn,
                isChecked: true,
                text:"RadioButton"
            ){ _ in
                
            }
            RadioButton(
                type: .switchOn,
                isChecked: true,
                text:"RadioButton",
                color: Color.app.black
            ){ _ in
                
            }
            RadioButton(
                type: .stroke,
                isChecked: true,
                text:"RadioButton"
            ){ _ in
                
            }
            RadioButton(
                type: .checkOn,
                isChecked: false,
                text:"RadioButton"
            ){ _ in
                
            }
        }
        .padding(.all, 10)
    }
}
#endif

