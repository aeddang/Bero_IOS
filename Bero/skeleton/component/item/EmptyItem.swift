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
        case myList, chat
        var image:String?{
            switch self {
            case .myList : return Asset.icon.paw
            case .chat : return Asset.image.addDog
            }
        }
        
        var imageMode:Image.TemplateRenderingMode{
            switch self {
            case .myList : return .template
            case .chat : return .original
            }
        }
        
        var imageHeight:CGFloat{
            switch self {
            case .myList : return Dimen.icon.medium
            case .chat : return 104
            }
        }
        
        var spacing:CGFloat{
            switch self {
            case .myList : return Dimen.margin.tinyExtra
            case .chat : return Dimen.margin.medium
            }
        }
        var text:String?{
            switch self {
            case .myList : return "It’s empty!"
            case .chat : return "Looks like you haven't started any conversations yet! Add friends to your list and start new chats."
            }
        }
        var bgColor:Color{
            switch self {
            case .myList : return Color.app.grey50
            case .chat : return Color.transparent.clear
            }
        }
        var radius:CGFloat{
            switch self {
            case .myList : return Dimen.radius.light
            case .chat : return 0
            }
        }
    }
    
    var type:ListType = .myList
    var body: some View {
        ZStack{
            VStack(spacing:self.type.spacing){
                if let img = self.type.image{
                    Image(img)
                        .renderingMode(self.type.imageMode)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.app.grey200)
                        .modifier(MatchHorizontal(height: self.type.imageHeight))
                }
                if let text = self.type.text{
                    Text(text)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,color: Color.app.grey300))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.all, Dimen.margin.regular)
        }
        .background(self.type.bgColor)
        .clipShape(RoundedRectangle(cornerRadius: self.type.radius))
    }
}


struct EmptyData: PageComponent{
    var text:String? = nil
    var image:String = Asset.image.addDog
    var body: some View {
        ZStack{
            Spacer().modifier(MatchHorizontal(height: 0))
            VStack(spacing:Dimen.margin.tinyExtra){
                if let text = self.text{
                    Text(text)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,color: Color.app.grey300))
                }
                
                Image(self.image)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 128)
                
            }
        }
    }
}


#if DEBUG
struct EmptyItem_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            EmptyItem(
                type: .myList
            )
            EmptyData(
                text: "ttttteeeeeessssstttttttt"
            )
        }
        .padding(.all, 10)
        .background(Color.app.whiteDeep)
    }
}
#endif
