//
//  ComponentTabNavigation.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct MenuTab : PageComponent {
    enum TabType{
        case line, box
        var strokeWidth:CGFloat{
            switch self {
            case .line : return 0
            case .box : return Dimen.stroke.light
            }
        }
        var radius:CGFloat{
            switch self {
            case .line : return 0
            case .box: return Dimen.radius.medium
           
            }
        }
        var textSize:CGFloat{
            switch self {
            case .line : return Font.size.light
            case .box: return Font.size.thin
            }
        }
        
        
        func bgColor(_ color:Color) ->Color{
            switch self {
            case .line : return Color.transparent.clearUi
            case .box : return color
            }
        }
        
        var btnBgColor : Color{
            switch self {
            case .line : return Color.transparent.clearUi
            case .box : return Color.app.white
            }
        }
    }
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
    var scrollReader:ScrollViewProxy? = nil
    
    var type:TabType = .box
    var buttons:[String]
    var selectedIdx:Int = 0
    
    var color:Color = Color.brand.primary
    var bgColor:Color = Color.app.grey50
    var height:CGFloat = Dimen.button.regular
    var isDivision:Bool = true
    @State var menus:[MenuBtn] = []
   
    var body: some View {
        HStack(spacing:0){
            ForEach(self.menus) { menu in
                Button(
                    action: {
                        if let scrollReader = self.scrollReader {
                            if menu.idx < self.menus.count-2 {
                                withAnimation{scrollReader.scrollTo(menu.hashIdx, anchor: .center)}
                            }
                        }
                        self.performAction(menu)
                        
                    }
                ){
                    ZStack(alignment: .bottom){
                        if self.isDivision {
                            self.createButton(menu)
                                .modifier(MatchParent())
                        } else {
                            self.createButton(menu)
                                .frame(height: self.height)
                        }
                        if self.type == .line {
                            Spacer().modifier(
                                LineHorizontal(
                                    height : menu.idx == self.selectedIdx ? Dimen.line.regular :  Dimen.line.light,
                                    color: menu.idx == self.selectedIdx ? self.color : Color.app.grey100)
                            )
                        }
                    }
                }
                .id(menu.hashIdx)
                .background(
                    menu.idx == self.selectedIdx
                        ? self.type.btnBgColor
                        : Color.transparent.clearUi)
                .clipShape( RoundedRectangle(cornerRadius: self.type.radius) )
                .overlay(
                    RoundedRectangle(cornerRadius: self.type.radius, style: .circular)
                        .strokeBorder(
                            Color.brand.primary  ,
                            lineWidth: menu.idx == self.selectedIdx
                            ? self.type.strokeWidth : 0 )
                )
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .frame(height: self.height)
        .background(self.type.bgColor(self.bgColor))
        .clipShape( RoundedRectangle(cornerRadius: self.type.radius))
        .onAppear(){
            self.menus = zip(0..<self.buttons.count, self.buttons).map{ idx, btn in
                MenuBtn(idx: idx, text: btn)
            }
        }
        
    }//body
    
    func createButton(_ menu:MenuBtn) -> some View {
        return Text(menu.text)
            .kerning(Font.kern.thin)
            .modifier(BoldTextStyle(
                size: self.type.textSize,
                color: menu.idx == self.selectedIdx ? self.color : Color.app.grey400
            ))
            .padding(.horizontal, Dimen.margin.regular)
            .fixedSize(horizontal: true, vertical: false)
    }
    
    
    func performAction(_ menu:MenuBtn){
        self.viewModel.selected = menu.text
        self.viewModel.index = menu.idx
        
    }
    
    struct MenuBtn : SelecterbleProtocol, Identifiable {
        let id = UUID().uuidString
        let hashIdx:Int = UUID().hashValue
        var idx:Int = 0
        var text:String = ""
    }
}

#if DEBUG
struct MenuTab_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            ForEach(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in
                MenuTab(
                    viewModel:NavigationModel(),
                    buttons: [
                        "normal", "normal"
                    ]
                )
                .frame( alignment: .center)
            }
            
            MenuTab(
                viewModel:NavigationModel(),
                type:.line,
                buttons: [
                    "normal", "normal"
                ]
            )
            .frame( alignment: .center)
        }
        .background(Color.app.white)
    }
}
#endif
