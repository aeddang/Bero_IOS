//
//  LayoutAli.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



struct LayoutTop: ViewModifier {
    var geometry:GeometryProxy
    var height:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.height - height)/2.0)
        return content
            .frame(height:height)
            .offset(y:-pos + margin)
    }
}

struct LayoutBotttom: ViewModifier {
    var geometry:GeometryProxy
    var height:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.height - height)/2.0)
        return content
            .frame(height:height)
            .offset(y:pos - margin)
    }
}

struct LayoutLeft: ViewModifier {
    var geometry:GeometryProxy
    var width:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.width - width)/2.0) - margin
        return content
            .frame(width:width)
            .offset(x:-pos)
    }
}

struct LayoutRight: ViewModifier {
    var geometry:GeometryProxy
    var width:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        let pos = ((geometry.size.width - width)/2.0) + margin
        return content
            .frame(width:width)
            .offset(x:pos)
    }
}

struct LayoutCenter: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}


struct PageAll: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .modifier(PageVertical())
            .modifier(PageHorizontal())
    }
}
struct PageTop: ViewModifier {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    func body(content: Content) -> some View {
        return content
            .padding(.top, self.appSceneObserver.safeHeaderHeight + Dimen.margin.regular)
    }
}
struct PageVertical: ViewModifier {
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    func body(content: Content) -> some View {
        return content
            .padding(.top, self.appSceneObserver.safeHeaderHeight + Dimen.margin.regular)
            .padding(.bottom, self.appSceneObserver.safeBottomHeight)
    }
}

struct PageHorizontal: ViewModifier {
   
    func body(content: Content) -> some View {
        return content
            .padding(.horizontal, Dimen.app.pageHorinzontal)
    }
}



struct ContentTab: ViewModifier {
    var margin:CGFloat = Dimen.margin.regular
    var bgColor:Color = Color.app.white
    func body(content: Content) -> some View {
        return content
            .padding(.all, margin)
            .background(bgColor)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.light))
            .modifier(Shadow())
    }
}

struct BottomFunctionTab: ViewModifier {
    var margin:CGFloat = Dimen.margin.regular
    var bgColor:Color = Color.app.white
    var effectPct:CGFloat = 1
    func body(content: Content) -> some View {
        return content
            .padding(.all, margin)
            .background(bgColor)
            .mask(
                ZStack(alignment: .bottom){
                    RoundedRectangle(cornerRadius: Dimen.radius.medium * effectPct)
                    Rectangle().modifier(MatchHorizontal(height: Dimen.radius.medium))
                }
            )
            .modifier(ShadowTop(opacity: 0.12 * effectPct))
    }
}
