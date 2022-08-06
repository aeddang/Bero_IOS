//
//  strings.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

extension String {
    func loaalized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    struct app {
        public static let appName = "appName"
        public static let confirm = "Confirm"
        public static let cancel = "Cancel"
        
        public static let male = "Male"
        public static let female = "Female"
        
        public static let kmPerH = "kmPerH"
        public static let km = "km"
        public static let min = "min"
    }
    
    struct gnb {
        public static let walk = "Walk"
        public static let matching = "Matching"
        public static let diary = "Diary"
        public static let my = "My"
    }
    
    struct location {
        public static let notFound = "locationNotFound"
    }
    
    struct alert {
        public static var apns = "alertApns"
        public static var api = "alertApi"
        public static var apiErrorServer = "alertApiErrorServer"
        public static var apiErrorClient = "alertApiErrorClient"
        public static var networkError = "alertNetworkError"
        public static var dataError = "alertDataError"
        
        public static var location = "locationTitle"
        public static var locationText = "need locationText"
        public static var locationBtn = "locationBtn"
        
        public static var snsLoginError = "After login. Available."
    }
    
    struct button {
        public static let close = "Close"
        public static let retry = "Retry"
        public static let reset = "Reset"
        public static let apply = "Apply"
        public static let more = "more"
        public static let delete = "Delete"
        public static let modify = "Modify"
        public static let album = "Album"
        public static let camera = "Camera"
      
    }
    
    struct pageTitle {
        public static let my = "titleMy"
        public static let addDog = "Add a dog"
    }
    
    struct pageText {
        public static let introText1_1 = "Walk your dog\nwith fun missions."
        public static let introText1_2 = "Walking dogs never been this\nfun! Explore new routes with\nthe daily and monthly missions."
        public static let introText2_1 = "Earn Encrypted\nCoins as you walk."
        public static let introText2_2 = "Walk your dog and earn\nfinancial rewards. The coins are\ndesignated to your dog!"
        public static let introText3_1 = "Make a local dog\ncommunity."
        public static let introText3_2 = "Find new local dog friends to\nwalk with and share\ninformation."
        public static let introComplete = "Let’s explore!"
        
        public static let loginText = "Let’s walk\nour dogs together!"
        public static let loginButtonText = "Continue with "
        
        
    }
    
}
