//
//  TextStyle.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/07.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct TextModifier {
    var family:String = Font.family.regular
    var size:CGFloat = Font.size.regular
    var spacing:CGFloat = Font.spacing.regular
    var color: Color = Color.app.black
    var activeColor: Color = Color.brand.primary
    var sizeScale: CGFloat = 1.1
    func getTextWidth(_ text:String) -> CGFloat{
        return text.textSizeFrom(fontSize: size * sizeScale).width
    }
    func getTextLineHeight() -> CGFloat{
        return self.size + 10
    }
}


struct BlackTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.black, size:Font.size.black)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.medium)
            .foregroundColor(textModifier.color)
            
    }
}

struct BoldTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.bold,size:Font.size.bold)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.regular)
            .foregroundColor(textModifier.color)
            
            
    }
}

struct SemiBoldTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.semiBold,size:Font.size.bold)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.regular)
            .foregroundColor(textModifier.color)
           
            
    }
}

struct MediumTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.medium,size:Font.size.medium, color:Color.app.black)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.regular)
            .foregroundColor(textModifier.color)
           
    }
}

struct RegularTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.regular,size:Font.size.regular)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.regular)
            .foregroundColor(textModifier.color)
            
    }
}

struct LightTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.light,size:Font.size.light)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.thin)
            .foregroundColor(textModifier.color)
            
    }
}


struct NumberBoldTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.bold,size:Font.size.bold)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.thin)
            .foregroundColor(textModifier.color)
            
    }
}

struct NumberMediumTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.medium,size:Font.size.medium)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.regular)
            .foregroundColor(textModifier.color)
            
    }
}

struct NumberLightTextStyle: ViewModifier {
    var textModifier = TextModifier(family:Font.family.light,size:Font.size.light)
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    init(size:CGFloat? = nil, color: Color? = nil) {
        if let size = size {
            self.textModifier.size = size
        }
        if let color = color {
            self.textModifier.color = color
            self.textModifier.activeColor = color
        }
        
    }
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.thin)
            .foregroundColor(textModifier.color)
            
    }
}



struct CustomTextStyle: ViewModifier {
    var textModifier:TextModifier
    init(textModifier:TextModifier) {self.textModifier = textModifier}
    func body(content: Content) -> some View {
        return content
            .font(.custom(textModifier.family, size: textModifier.size))
            .lineSpacing(Font.spacing.regular)
            .foregroundColor(textModifier.color)
           
    }
}


