//
//  TitleTab.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/20.
//

//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI

extension TitleTab{
    enum ButtonType:String {
        case more, add, edit, close, back
        case viewMore
        var icon:String {
            switch self {
            case .back : return Asset.icon.back
            case .more : return Asset.icon.more_vert
            case .add : return Asset.icon.add
            case .edit : return Asset.icon.edit
            case .close : return Asset.icon.close
            case .viewMore : return Asset.icon.direction_right
            }
        }
        var text:String? {
            switch self {
            case .viewMore : return "View more"
            default : return nil
            }
        }
        
        var color:Color {
            switch self {
            case .viewMore : return Color.app.grey400
            default : return Color.app.grey500 
            }
        }
    }
}


struct TitleTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var title:String? = nil
    var lineLimit:Int = 0
    var alignment:TextAlignment = .center
    var useBack:Bool = true
    var buttons:[ButtonType] = []
    var action: ((ButtonType) -> Void)
   
    var body: some View {
        ZStack(alignment:self.alignment == .leading || self.useBack ? .leading : .center){
            HStack(spacing: Dimen.margin.tiny){
                if useBack {
                    ImageButton(
                        defaultImage: Asset.icon.back
                    ){ _ in
                        self.action(.back)
                    }
                }
                if let title = self.title {
                    Text(title)
                        .modifier(BoldTextStyle(size: Font.size.light, color: Color.app.black))
                        .multilineTextAlignment(self.alignment)
                        .lineLimit(self.lineLimit)
                }
            }
            HStack(spacing: Dimen.margin.tiny){
                Spacer().modifier(MatchHorizontal(height: 0))
                ForEach(self.buttons, id: \.self) { btn in
                    HStack(spacing:Dimen.margin.microExtra){
                        if let text = btn.text {
                            Text(text)
                                .modifier(LightTextStyle(size: Font.size.thin, color: Color.app.grey400))
                                .onTapGesture {
                                    self.action(btn)
                                }
                        }
                        ImageButton(
                            defaultImage: btn.icon,
                            defaultColor: btn.color
                        ){ _ in
                            self.action(btn)
                        }
                    }
                }
                
            }
        }
    }
}

#if DEBUG
struct TitleTab_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            TitleTab(
                title: "title",
                buttons: [
                    .more, .viewMore
                ]
            ){ type in
                
            }
            .environmentObject(PagePresenter()).frame(width:320,height:100)
                
        }
    }
}
#endif

