//
//  FillButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit
struct SelectButton: View, SelecterbleProtocol{
    enum ButtonType{
        case tiny, small, medium
        var height:CGFloat{
            switch self {
            case .tiny : return Dimen.button.regular
            case .small : return Dimen.button.medium
            case .medium : return Dimen.button.heavy
            }
        }
        
        var radius:CGFloat{
            switch self {
            case .tiny : return Dimen.radius.thin
            case .small : return Dimen.radius.thin
            case .medium : return 0
            }
        }
    }
    var type:ButtonType = .small
    var icon:String? = nil
    var isOriginIcon:Bool = false
    var title:String? = nil
    var text:String
    var description:String? = nil
    var bgColor:Color = Color.app.white
    var index: Int = 0
    var isMore: Bool = true
    var useStroke: Bool = true
    var isSelected: Bool = false
    
    let action: (_ idx:Int) -> Void

    var body: some View {
        Button(action: {
            self.action(self.index)
        }) {
            HStack(spacing:Dimen.margin.light){
                if let icon = self.icon {
                    ZStack{
                        if self.type == .medium {
                            Circle().stroke(Color.app.grey200)
                                .frame(width: Dimen.circle.regular, height: Dimen.circle.regular)
                        }
                        if self.isOriginIcon {
                            Image(icon)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width:Dimen.icon.regular, height:Dimen.icon.regular)
                        } else {
                            Image(icon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(
                                    self.isSelected ? Color.brand.primary : Color.app.black)
                                .frame(width:Dimen.icon.regular, height:Dimen.icon.regular)
                        }
                        
                    }
                }
                VStack(alignment:.leading, spacing:0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    if let tip = self.title {
                        Text(tip)
                            .modifier(MediumTextStyle(
                                size: Font.size.thin, color: Color.app.grey400))
                    }
                    Text(self.text)
                        .modifier(MediumTextStyle(
                            size: Font.size.light,
                            color: self.isSelected ? Color.brand.primary : Color.app.black))
                    
                    if let tip = self.description {
                        Text(tip)
                            .modifier(MediumTextStyle(
                                size: Font.size.thin, color: Color.app.grey400))
                    }
                    
                }
                if self.isMore {
                    Image(Asset.icon.direction_right)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(
                            self.isSelected ? Color.brand.primary : Color.app.black)
                        .frame(width:Dimen.icon.light, height:Dimen.icon.light)
                }
                
            }
            .padding(.horizontal, Dimen.margin.light)
            .modifier( MatchHorizontal(height: self.type.height) )
            .background(self.bgColor)
            .clipShape(RoundedRectangle(cornerRadius:  self.type.radius))
            .overlay(
                RoundedRectangle(cornerRadius: self.type.radius)
                    .strokeBorder(
                        self.isSelected ? Color.brand.primary : Color.app.grey200,
                        lineWidth: self.useStroke ? Dimen.stroke.light : 0
                    )
            )
        }
        
        
    }
}
#if DEBUG
struct SelectButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SelectButton(
                type: .tiny,
                icon: Asset.icon.album,
                text: "tiny button",
                description: "select",
                isSelected: true
            ){_ in
                
            }
            SelectButton(
                type: .small,
                icon: Asset.icon.album,
                text: "small button",
                description: "select",
                isSelected: true
            ){_ in
                
            }
            SelectButton(
                type: .medium,
                icon: Asset.icon.album,
                text: "medium button",
                description: "unselect",
                isSelected: false
            ){_ in
                
            }
            
            SelectButton(
                type: .medium,
                title: "title no icon",
                text: "medium button",
                useStroke: false,
                isSelected: false
            ){_ in
                
            }
        }
        .padding(.all, 10)
    }
}
#endif

