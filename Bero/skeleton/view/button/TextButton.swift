//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import FirebaseAnalytics
struct TextButton: View, SelecterbleProtocol, PageProtocol{
    var defaultText:String
    var isSelected: Bool = false
    var index: Int = 0
    var activeText:String? = nil
    var textModifier:TextModifier = TextModifier(
        family: Font.family.semiBold,
        size: Font.size.light,
        color: Color.app.black,
        activeColor: Color.brand.primary)
    
    var isUnderLine:Bool = false
    var image:String? = nil
    var imageSize:CGFloat = Dimen.icon.tiny
    var spacing:CGFloat = Dimen.margin.tiny
    let action: (_ idx:Int) -> Void
    
    var body: some View {
        Button(action: {
            self.action(self.index)
            let parameters = [
                "buttonType": self.tag,
                "buttonText": defaultText
            ]
            Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
        }) {
            HStack(alignment:.center, spacing: spacing){
                if self.isUnderLine {
                    Text(self.isSelected ? ( self.activeText ?? self.defaultText ) : self.defaultText)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .underline()
                    .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    .lineLimit(1)
                } else {
                    
                    Text(self.isSelected ? ( self.activeText ?? self.defaultText ) : self.defaultText)
                    .font(.custom(textModifier.family, size: textModifier.size))
                    .foregroundColor(self.isSelected ? textModifier.activeColor : textModifier.color)
                    .lineLimit(1)
                }
                if self.image != nil {
                    Image(self.image!)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(width: self.imageSize, height: self.imageSize)
                    .padding(.bottom, 1)
                }
            }
        }.buttonStyle(BorderlessButtonStyle())
    }
}

#if DEBUG
struct TextButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            TextButton(
                defaultText:"test",
                isUnderLine: true,
                image: Asset.noImg1_1
                ){_ in
                
            }
            .frame( alignment: .center)
        }
    }
}
#endif
