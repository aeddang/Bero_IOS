//
//  dimens.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

struct Dimen{
    struct margin {
        public static let heavy:CGFloat = 56
        public static let heavyExtra:CGFloat = 48
        public static let mediumUltra:CGFloat = 40
        public static let medium:CGFloat = 32
        public static let regularUltra:CGFloat = 24
        public static let regular:CGFloat = 20
        public static let regularExtra:CGFloat = 16
        public static let light:CGFloat = 14
        public static let thin:CGFloat = 12
        public static let tiny:CGFloat = 10
        public static let tinyExtra:CGFloat = 8
        public static let microUltra:CGFloat = 6
        public static let micro:CGFloat = 4
        public static let microExtra:CGFloat = 2
    }

    struct icon {
        public static let heavyUltra:CGFloat = 72
        public static let heavy:CGFloat = 64
        public static let heavyExtra:CGFloat = 48
        public static let mediumUltra:CGFloat = 40
        public static let medium:CGFloat = 32
        public static let regular:CGFloat = 28
        public static let light:CGFloat = 24
        public static let thin:CGFloat = 20
        public static let tiny:CGFloat = 16
        public static let microUltra:CGFloat = 8
        public static let micro:CGFloat = 4
        
    }
    
    struct profile {
        public static let heavy:CGFloat = 120
        public static let heavyExtra:CGFloat = 96
        public static let mediumUltra:CGFloat = 84
        public static let medium:CGFloat = 80
        public static let regular:CGFloat = 56
        public static let light:CGFloat = 48
        public static let lightExtra:CGFloat = 46
        public static let thin:CGFloat = 40
        public static let tiny:CGFloat = 32
    }
    
    struct tab {
        public static let heavy:CGFloat = 88
        public static let medium:CGFloat = 52
        public static let regular:CGFloat = 46
        public static let light:CGFloat = 36//
        public static let thin:CGFloat = 24//
    }
    
    struct button {
        
        public static let heavy:CGFloat = 72
        public static let medium:CGFloat = 56
        public static let mediumExtra:CGFloat = 52
        
        public static let regular:CGFloat = 48
        public static let regularExtra:CGFloat = 40
        public static let light:CGFloat = 36 
        public static let thin:CGFloat = 32 //
       
    }

    struct radius {
        public static let heavy:CGFloat = 32
        public static let mediumUltra:CGFloat = 28
        public static let medium:CGFloat = 24
        public static let regular:CGFloat = 20
        public static let light:CGFloat = 16
        public static let lightExtra:CGFloat = 14
        public static let thin:CGFloat = 12
        public static let thinExtra:CGFloat = 10
        public static let tiny:CGFloat = 8
        public static let micro:CGFloat = 4//
    }
    
    struct circle {
        public static let regular:CGFloat = 40
        public static let thin:CGFloat = 4
    }
    
    struct bar {
        public static let medium:CGFloat = 34 //
        public static let regular:CGFloat = 16
        public static let light:CGFloat = 4 
    }
    
    struct line {
        public static let heavy:CGFloat = 12
        public static let medium:CGFloat = 6//
        public static let regular:CGFloat =  2
        public static let light:CGFloat = 1
    }
    
    
    struct stroke {
        public static let heavyUltra:CGFloat =  5
        public static let heavy:CGFloat =  4
        public static let medium:CGFloat =  3
        public static let regular:CGFloat = 2
        public static let light:CGFloat = 1
    }
    
    struct app {
        public static let bottom:CGFloat = 64
        public static let top:CGFloat = 50
        public static let chatBox:CGFloat = 64
        public static let pageHorinzontal:CGFloat = Dimen.margin.regular
    }
    
}

