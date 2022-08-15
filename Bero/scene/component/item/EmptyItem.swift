//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct EmptyItem: PageComponent{
    enum ListType{
        case myList
        var image:String?{
            switch self {
            case .myList : return Asset.icon.paw
            }
        }
        var height:CGFloat{
            switch self {
            case .myList : return 92
            }
        }
        var text:String?{
            switch self {
            case .myList : return "It’s empty!"
            }
        }
        var radius:CGFloat{
            switch self {
            case .myList : return Dimen.radius.light
            }
        }
    }
    
    var type:ListType = .myList
    var body: some View {
        ZStack{
            VStack(spacing:Dimen.margin.tinyExtra){
                if let img = self.type.image{
                    Image(img)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.app.grey200)
                        .frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
                }
                if let text = self.type.text{
                    Text(text)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,color: Color.app.grey300))
                }
            }
        }
        .modifier(MatchHorizontal(height: self.type.height))
        .background(Color.app.grey50)
        .clipShape(RoundedRectangle(cornerRadius: self.type.radius))
    }
}



#if DEBUG
struct EmptyItem_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            EmptyItem(
                type: .myList
            )
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
