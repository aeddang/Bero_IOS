//
//  Tipografi.swift
//  Bero
//
//  Created by JeongCheol Kim on 2023/07/10.
//

import Foundation
import SwiftUI

struct Tipo:Identifiable{
    let id = UUID().uuidString
    let value:String
    var style:CustomTextStyle = .init(textModifier: RegularTextStyle().textModifier)
}

/*
struct Tipografi: PageView {
    var values:[Tipo] = []
    var body: some View {
        Text("")
        ForEach(self.values){ tipo in
            + Text(tipo.value).modifier(tipo.style)
        }
    }
}
*/
#if DEBUG
struct Tipografi_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            
        }
    }
}
#endif
