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
struct AgreeButton: View, SelecterbleProtocol, PageProtocol {
    @EnvironmentObject var pagePresenter:PagePresenter
    enum ButtonType{
        case privacy, service, neutralized
        var icon:String?{
            switch self {
            case .neutralized : return Asset.icon.neutralized
            default : return nil
            }
        }
        var text:String{
            switch self {
            case .neutralized : return "Neutralized/Spayed"
            case .privacy : return "Privacy Policy"
            case .service : return "Terms of service"
            }
        }
        
        var page:PageID?{
            switch self {
            case .privacy : return .privacy
            case .service : return .serviceTerms
            default : return nil
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
                    if let icon = self.type.icon {
                        Image(icon)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.light, height: Dimen.icon.light)
                            .opacity(self.isChecked ? 1 : 0.4)
                    }
                    Text(self.text ?? self.type.text)
                        .modifier( RegularTextStyle(
                            size: Font.size.light,
                            color: self.isChecked ? Color.app.black : Color.app.grey400
                        ))
                        .fixedSize()
                    if let page = self.type.page {
                        TextButton(
                            defaultText: String.button.terms,
                            isUnderLine: true
                        ){_ in
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(page)
                            )
                            let parameters = [
                                "buttonType": self.tag,
                                "buttonText": (text ?? "") + " more"
                            ]
                            Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
                        }
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
            let parameters = [
                "buttonType": self.tag,
                "buttonText": text ?? "",
                "isChecked" : isChecked.description
            ]
            Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
        }
            
    }
}

#if DEBUG
struct AgreeButton_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            AgreeButton(
                type: .neutralized,
                isChecked: true
            ){ _ in
                
            }
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

