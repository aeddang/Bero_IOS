//
//  LayoutAlignmentGroup.swift
//  Bero
//
//  Created by JeongCheol Kim on 2023/02/12.
//

import Foundation
import SwiftUI
struct MatchParent: ViewModifier {
    var marginX:CGFloat = 0
    var marginY:CGFloat = 0
    var margin:CGFloat? = nil
    func body(content: Content) -> some View {
        let mx = margin == nil ? marginX : margin!
        let my = margin == nil ? marginY : margin!
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (mx * 2.0), minHeight:0, maxHeight: .infinity - (my * 2.0))
            .offset(x:mx, y:my)
    }
}
struct MatchHorizontal: ViewModifier {
    var height:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (margin * 2.0) , minHeight: height, maxHeight: height)
            .offset(x:margin)
    }
}

struct MatchVertical: ViewModifier {
    var width:CGFloat = 0
    var margin:CGFloat = 0
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: width, maxWidth: width , minHeight:0, maxHeight: .infinity - (margin * 2.0))
            .offset(y:margin)
    }
}

struct LineHorizontal: ViewModifier {
    var height:CGFloat = Dimen.line.light
    var margin:CGFloat = 0
    var color:Color = Color.app.grey50
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (margin * 2.0) , minHeight: height, maxHeight: height)
            .offset(x:margin)
            .background(self.color)
            
            
    }
}
struct LineVertical: ViewModifier {
    var width:CGFloat = Dimen.line.light
    var margin:CGFloat = 0
    var color:Color = Color.app.grey50
    func body(content: Content) -> some View {
        return content
            .frame(minWidth: width, maxWidth: width , minHeight:0, maxHeight: .infinity - (margin * 2.0))
            .offset(y:margin)
            .background(self.color)
            
            
    }
}
struct LineHorizontalDotted: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
struct LineVerticalDotted: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y:rect.height))
        return path
    }
}

struct Shadow: ViewModifier {
    var color:Color = Color.app.black
    var opacity:Double = 0.12
    func body(content: Content) -> some View {
        return content
            .shadow(color: color.opacity(opacity), radius: Dimen.radius.tiny, x: 5, y: 5)
    }
}

struct ShadowLight: ViewModifier {
    var color:Color = Color.app.black
    var opacity:Double = 0.05
    func body(content: Content) -> some View {
        return content
            .shadow(color: color.opacity(opacity), radius: Dimen.radius.tiny, x: 2, y: 2)
    }
}

struct ShadowTop: ViewModifier {
    var color:Color = Color.app.black
    var opacity:Double = 0.12
    func body(content: Content) -> some View {
        return content
            .shadow(color: color.opacity(opacity), radius: Dimen.radius.tiny, x: 0, y: -5)
    }
}

struct ShadowBottom: ViewModifier {
    var color:Color = Color.app.black
    var opacity:Double = 0.12
    func body(content: Content) -> some View {
        return content
            .shadow(color: color.opacity(opacity), radius: Dimen.radius.tiny, x: 0, y: 5)
    }
}
