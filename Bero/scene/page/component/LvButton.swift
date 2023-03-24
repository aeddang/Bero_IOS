//
//  HeartButton.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/09/03.
//

import Foundation
import SwiftUI
import FirebaseAnalytics
struct LvButton: View, SelecterbleProtocol, PageProtocol{
    enum ButtonType{
        case small, big, tiny
        
        var size:CGFloat{
            switch self {
            case .big : return Dimen.profile.heavyExtra
            case .small : return Dimen.icon.mediumUltra
            case .tiny : return Dimen.icon.thin
            }
        }
        var textSize:CGFloat{
            switch self {
            case .big : return Font.size.bold
            case .small : return Font.size.tiny
            case .tiny : return Font.size.microExtra
            }
        }
        var textTop:CGFloat{
            switch self {
            case .big : return 28
            case .small : return 10
            case .tiny : return 6
            }
        }
    }
    var lv:Lv = .green
    var type:ButtonType = .small
    var text:String? = nil
    var defaultColor:Color = Color.app.grey100
    var activeColor:Color? = nil
    var isSelected: Bool = true
    var index: Int = -1
    let action: (_ idx:Int) -> Void
   
    var body: some View {
        Button(action: {
            self.action(self.index)
            let parameters = [
                "buttonType": self.tag,
                "buttonText": text ?? "",
                "isSelected" : isSelected.description
            ]
            Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
        }) {
            ZStack(){
                Image(self.lv.icon)
                    .renderingMode(self.isSelected ? .original : .template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: self.type.size, height: self.type.size)
                    .foregroundColor(self.isSelected
                                     ? self.activeColor ?? self.lv.color
                                     : self.defaultColor)
                    
                if let text = self.text {
                    Text(text)
                        .modifier(BoldTextStyle(
                            size: self.type.textSize,
                            color: Color.app.white
                        ))
                        .padding(.top, self.type.textTop)
                }
            }
        }
    }
}

#if DEBUG
struct HeartButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack{
            LvButton(
                type: .big,
                text: "LV.99",
                isSelected: true
            ){_ in
                
            }
            LvButton(
                type: .tiny,
                text: "99",
                isSelected: true
            ){_ in
                
            }
            LvButton(
                text: "12",
                isSelected: true
            ){_ in
                
            }
        }
    }
}
#endif




