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
    enum TitleType{
        case page, section
        
        var textFamily:String {
            switch self {
            case .page : return Font.family.bold
            case .section : return Font.family.bold
            }
        }
        var textSize:CGFloat {
            switch self {
            case .page : return Font.size.black
            case .section : return Font.size.regular
            }
        }
    }
    
    enum ButtonType:String{
        case more, add, edit, close, back, setting, alramOn, alram
        case viewMore, manageDogs
        var icon:String {
            switch self {
            case .back : return Asset.icon.back
            case .more : return Asset.icon.more_vert
            case .add : return Asset.icon.add
            case .edit : return Asset.icon.edit
            case .close : return Asset.icon.close
            case .alram : return Asset.icon.notification_off
            case .alramOn : return Asset.icon.notification_on
            case .setting : return Asset.icon.settings
            case .viewMore, .manageDogs : return Asset.icon.direction_right
            }
        }
        var text:String? {
            switch self {
            case .viewMore : return "View more"
            case .manageDogs : return "Manage dogs"
            default : return nil
            }
        }
        
        var color:Color {
            switch self {
            case .viewMore, .manageDogs : return Color.app.grey400
            default : return Color.app.grey500 
            }
        }
    }
}


struct TitleTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var type:TitleType = .page
    var title:String? = nil
    var lineLimit:Int = 0
    var alignment:TextAlignment = .leading
    var useBack:Bool = false
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
                        .font(.custom(
                            self.type.textFamily,
                            size: self.type.textSize)
                        )
                        .lineSpacing(Font.spacing.regular)
                        .foregroundColor(Color.app.black)
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
                                .modifier(RegularTextStyle(size: Font.size.thin, color: Color.app.grey400))
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
        VStack{
            TitleTab(
                type: .page,
                title: "Page Title",
                useBack: false,
                buttons: [
                    .alram, .setting
                ]
            ){ type in
                
            }
            TitleTab(
                type: .section,
                title: "Menu Title",
                buttons: [
                    .viewMore
                ]
            ){ type in
                
            }
                
        }
        .frame(width: 320, height: 600)
    }
}
#endif

