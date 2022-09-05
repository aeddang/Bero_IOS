//
//  CharacterSelectBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2021/01/04.
//

import Foundation
import SwiftUI



struct ReportText: PageComponent{

    var leading:String = ""
    var value:String = ""
    var trailing:String = ""
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0){
            Spacer().modifier(MatchHorizontal(height: 0))
            Text(self.leading)
                .font(.custom(Font.family.semiBold, size: Font.size.medium))
                .foregroundColor(Color.app.black)
            + Text(" "+self.value)
                .font(.custom(Font.family.semiBold, size: Font.size.medium))
                .foregroundColor(Color.brand.primary)
            
            Text(self.trailing)
                .font(.custom(Font.family.semiBold, size: Font.size.medium))
                .foregroundColor(Color.app.black)
            
        }
        
    }//body
    
    
}


#if DEBUG
struct ReportText_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            ReportText(
                leading: "leading",
                value: "value",
                trailing: "trailing")
            .frame(width:320,height:600)
        }
    }
}
#endif
