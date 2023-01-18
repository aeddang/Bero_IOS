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
            case .page : return Font.family.semiBold
            case .section : return Font.family.semiBold
            }
        }
        var textSize:CGFloat {
            switch self {
            case .page : return Font.size.bold
            case .section : return Font.size.light
            }
        }
        
        var margin:CGFloat {
            switch self {
            case .page : return Dimen.app.pageHorinzontal
            case .section : return 0
            }
        }
        var marginBottom:CGFloat {
            switch self {
            case .page : return Dimen.margin.thin
            case .section : return 0
            }
        }
    }
    
    enum ButtonType:String{
        case more, add, edit, close, back, setting, alramOn, alram, block
        case addFriend,friend
        case viewMore, manageDogs
        var icon:String? {
            switch self {
            case .back : return Asset.icon.back
            case .more : return Asset.icon.more_vert
            case .add : return Asset.icon.add
            case .edit : return nil
            case .close : return Asset.icon.close
            case .alram : return Asset.icon.notification_off
            case .alramOn : return Asset.icon.notification_on
            case .setting : return Asset.icon.settings
            case .viewMore, .manageDogs : return Asset.icon.direction_right
            case .addFriend : return Asset.icon.add_friend
            case .friend : return Asset.icon.my
            case .block : return Asset.icon.block
            }
        }
        var text:String? {
            switch self {
            case .edit : return String.button.edit
            case .viewMore : return String.button.viewMore
            case .manageDogs : return String.button.manageDogs
            default : return nil
            }
        }
        
        var color:Color {
            switch self {
            case .edit : return Color.brand.primary
            case .viewMore, .manageDogs : return Color.app.grey400
            default : return Color.app.grey500 
            }
        }
    }
}


struct TitleTab: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var type:TitleType = .page
    var title:String? = nil
    var lineLimit:Int = 0
    var alignment:TextAlignment = .leading
    var useBack:Bool = false
    var margin:CGFloat? = nil
    var sortPetProfile:PetProfile? = nil
    var sortButton:String? = nil
    var sort:(() -> Void)? = nil
    var buttons:[ButtonType] = []
    var icons:[String?] = []
    var action: ((ButtonType) -> Void)? = nil
   
    @State private var isTop:Bool = true
    var body: some View {
        VStack(spacing:0){
            ZStack(alignment:self.alignment == .leading ? .leading : .center){
                HStack(spacing: Dimen.margin.tiny){
                    if useBack {
                        ImageButton(
                            defaultImage: Asset.icon.back
                        ){ _ in
                            self.action?(.back)
                        }
                    }
                    if let title = self.title {
                        if self.alignment == .leading {
                            Text(title)
                                .font(.custom(
                                    self.type.textFamily,
                                    size: self.type.textSize)
                                )
                                .lineSpacing(Font.spacing.regular)
                                .foregroundColor(Color.app.black)
                                .multilineTextAlignment(self.alignment)
                                .lineLimit(self.lineLimit)
                        } else {
                            Text(title)
                                .font(.custom(
                                    self.type.textFamily,
                                    size: self.type.textSize)
                                )
                                .lineSpacing(Font.spacing.regular)
                                .foregroundColor(Color.app.black)
                                .multilineTextAlignment(self.alignment)
                                .lineLimit(self.lineLimit)
                                .modifier(MatchHorizontal(height: self.type.textSize ))
                                .padding(.trailing, Dimen.icon.light)
                        }
                       
                    }
                }
                
                HStack(spacing: Dimen.margin.tiny){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    if let btn = self.sortButton {
                        SortButton(
                            type: .stroke,
                            sizeType: .big,
                            petProgile:self.sortPetProfile,
                            text: btn,
                            color:Color.app.grey400,
                            isSort: true){
                                self.sort?()
                            }
                    }
                    ForEach( Array(self.buttons.enumerated()), id: \.1){ idx,  btn in
                        HStack(spacing:Dimen.margin.microExtra){
                            if let text = btn.text {
                                Text(text)
                                    .modifier(RegularTextStyle(size: Font.size.thin, color: btn.color))
                                    .onTapGesture {
                                        self.action?(btn)
                                    }
                            }
                            if let icon = btn.icon {
                                if self.icons.count > idx, let iconText = self.icons[idx] {
                                    ImageButton(
                                        defaultImage: icon,
                                        iconText:iconText,
                                        defaultColor: btn.color
                                    ){ _ in
                                        self.action?(btn)
                                    }
                                } else {
                                    ImageButton(
                                        defaultImage: icon,
                                        defaultColor: btn.color
                                    ){ _ in
                                        self.action?(btn)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.bottom, self.type.margin)
            .padding(.horizontal, self.margin ?? self.type.margin)
            
            //if self.type == .page {
                Spacer().modifier(LineHorizontal())
                    .modifier(ShadowBottom())
                    .opacity(self.isTop ? 0 : 1)
            //}
        }
        .onReceive(self.infinityScrollModel.$event){ evt  in
            guard let evt = evt else {return}
            
            withAnimation{
                switch evt {
                case .up, .down : self.isTop = false
                case .top : self.isTop = true
                default : break
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
        .background(Color.app.whiteDeep)
    }
}
#endif

