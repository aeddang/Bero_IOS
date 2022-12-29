//
//  UnitConverter.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import SwiftUI
import UIKit
import CryptoKit






extension Date{
    
    func getDDay() -> Int {
        Int(ceil(self.timeIntervalSince(AppUtil.networkTimeDate()) / (24*60*60))) - 1
    }

    func toAge(trailing:String = "", isKr:Bool = false)->String{
        let now = AppUtil.networkTimeDate()
        let yy = now.toDateFormatter(dateFormat:"yyyy")
        let birthYY = self.toDateFormatter(dateFormat:"yyyy")
        let age = yy.toInt() - birthYY.toInt()
        if isKr {
            return (age + 1).description + trailing
        } else {
            let md = now.toDateFormatter(dateFormat:"MMdd")
            let birthMD = self.toDateFormatter(dateFormat:"MMdd")
            return md < birthMD ?  age.description + trailing : (age + 1).description + trailing
        }
    }
}

