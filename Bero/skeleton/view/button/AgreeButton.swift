//
//  CheckBox.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/20.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct AgreeButton: View, SelecterbleProtocol {
    @EnvironmentObject var pagePresenter:PagePresenter
    enum ButtonType{
        case privacy, service
        
        var text:String{
            switch self {
            case .privacy : return "Privacy usage agreement"
            case .service : return "Terms of service agreement"
            }
        }
        
        var page:PageID{
            switch self {
            case .privacy : return .privacy
            case .service : return .serviceTerms
            }
        }
    }
    var type:ButtonType = .privacy
    var isChecked: Bool
    var text:String? = nil
   
    var action: (_ check:Bool) -> Void
    var body: some View {
        HStack(alignment: .center, spacing: 0){
            VStack(alignment: .leading, spacing: 0){
                Spacer().modifier(MatchHorizontal(height: 0))
                HStack(spacing: Dimen.margin.tiny){
                    Text(self.text ?? self.type.text)
                        .modifier( RegularTextStyle(
                            size: Font.size.light,
                            color: self.isChecked ? Color.app.black : Color.app.grey400
                        ))
                        .fixedSize()
                    TextButton(
                        defaultText: String.button.terms,
                        isUnderLine: true
                    ){_ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(self.type.page)
                        )
                    }
                }
            }
            
            Image(Asset.icon.checked_circle)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(self.isChecked ? Color.brand.primary : Color.app.grey200)
                .frame(width: Dimen.icon.light, height: Dimen.icon.light)
            
        }
        .onTapGesture {
            action(!self.isChecked)
        }
            
    }
}

#if DEBUG
struct AgreeButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            AgreeButton(
                type: .privacy,
                isChecked: true
            ){ _ in
                
            }
            AgreeButton(
                type: .service,
                isChecked: true
            ){ _ in
                
            }
            
        }
        .padding(.all, 10)
    }
}
#endif

