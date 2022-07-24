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
    var isChecked: Bool
    var text:String? = nil
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
                                color: self.isChecked ? Color.brand.primary : Color.app.grey400
                            ))
                    }
                }
                if self.isChecked {
                    Image(Asset.icon.check)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.brand.primary)
                        .frame(width: Dimen.icon.light, height: Dimen.icon.light)
                }
            }
            .frame(height: Dimen.icon.light)
        }
    }
}

#if DEBUG
struct RadioButton_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RadioButton(
                isChecked: true,
                text:"RadioButton"
            ){ _ in
                
            }
        }
        
    }
}
#endif

