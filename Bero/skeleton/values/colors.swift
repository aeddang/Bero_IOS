//
//  colors.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
extension Color {
    init(rgb: Int) {
        let r = Double((rgb >> 16) & 0xFF)/255.0
        let g = Double((rgb >> 8) & 0xFF)/255.0
        let b = Double((rgb ) & 0xFF)/255.0
        self.init(
            red: r,
            green: g,
            blue: b
        )
    }
    
    struct brand {
        public static let primary = Color.app.orange
        public static let secondary = Color.app.green
        public static let thirdly = Color.app.red
        public static let bg = Color.app.white //Color.init(rgb: 0xEEEEEE)
    }
    struct app {
        public static let orange = Color.init(rgb: 0xFF7D1F)
        public static let orangeSub = Color.init(rgb:0xFFF1E7)
        public static let orangeSub2 = Color.init(rgb:0xFFD2B1)
       
    
        public static let orangeGradient:Gradient = Gradient(colors: [
            Color.init(red: 249/255, green: 149/255, blue: 31/255),
            Color.init(red: 255/255, green: 133/255, blue: 65/255)
        ])
        
        public static let green = Color.init(rgb:0x13CEA1)
        public static let greenDeep = Color.init(rgb:0x00B189)
        public static let red = Color.init(rgb:0xF2270B)
        public static let blue = Color.init(rgb:0x88A1FB)
        public static let sky = Color.init(rgb:0x5EB3E4)
        public static let brown = Color.init(rgb:0x965F36)
        public static let pink = Color.init(rgb:0xFA7598)
        public static let yellow = Color.init(rgb:0xFFE749)
        public static let yellowDeep = Color.init(rgb:0xFFAC2F)
        public static let yellowSub = Color.init(rgb:0xFFF4D7)
        
        public static let black =  Color.init(rgb: 0x333333)
        
        public static let white =  Color.white
        public static let whiteDeepLight =  Color.init(red: 249/255, green: 249/255, blue: 251/255)
        public static let whiteDeep =  Color.init(rgb: 0xDEDEDE)
    
        public static let grey50 = Color.init(rgb: 0xF9F9FB)
        public static let grey100 = Color.init(rgb: 0xF1F2F5)
        public static let grey200 = Color.init(rgb: 0xD4D8E1)
        public static let grey300 = Color.init(rgb: 0xA7ABB5)
        public static let grey400 = Color.init(rgb: 0x7C818B)
        public static let grey500 = Color.init(rgb: 0x545861)
    }
    
    struct transparent {
        public static let clear = Color.black.opacity(0.0)
        public static let clearUi = Color.black.opacity(0.0001)
        public static let black70 = Color.black.opacity(0.7)
        public static let black50 = Color.black.opacity(0.5)
        public static let black45 = Color.black.opacity(0.45)
        public static let black15 = Color.black.opacity(0.15)
       
    }
}


