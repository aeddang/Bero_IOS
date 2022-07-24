//
//  CheckBox.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct CheckBox: View, SelecterbleProtocol {
    var isChecked: Bool
    var text:String? = nil
    var subText:String? = nil
   
    var more: (() -> Void)? = nil
    var action: ((_ check:Bool) -> Void)? = nil
    
    
    var body: some View {
        HStack(alignment: .top, spacing: Dimen.margin.thin){
           ImageButton(
            isSelected: self.isChecked,
            defaultImage: Asset.icon.check,
            activeImage: Asset.icon.checked_circle,
            size: CGSize(width: Dimen.icon.thin, height: Dimen.icon.thin)
                ){_ in
                    if self.action != nil {
                        self.action!(!self.isChecked)
                    }
            }
            VStack(alignment: .leading, spacing: Dimen.margin.tiny){
                if self.text != nil {
                    Text(self.text!)
                        .modifier( MediumTextStyle(
                                size: Font.size.thin,
                                color: Color.app.white)
                        )
                }
                if self.subText != nil {
                    Text(self.subText!)
                        .modifier(MediumTextStyle(
                            size: Font.size.thin,
                            color: Color.app.black))
                }
            }.offset(y:3)
            Spacer()
            if more != nil {
                TextButton(
                    defaultText: String.button.more,
                    textModifier:TextModifier(
                        family:Font.family.medium,
                        size:Font.size.thin,
                        color: Color.app.white),
                    isUnderLine: true)
                {_ in
                    self.more!()
                }
            }
        }
    }
}

#if DEBUG
struct CheckBox_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CheckBox(
                isChecked: true,
                text:"asdafafsd",
                more:{
                    
                },
                action:{ ck in
                
                }
            )
            .frame( alignment: .center)
            .background(Color.brand.bg)
        }
        
    }
}
#endif

