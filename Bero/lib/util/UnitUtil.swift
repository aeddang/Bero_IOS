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

    func toAge(trailing:String = "Y", subTrailing:String = "M", isKr:Bool = false)->String{
        let now = AppUtil.networkTimeDate()
        let yy = now.toDateFormatter(dateFormat:"yyyy")
        let birthYY = self.toDateFormatter(dateFormat:"yyyy")
        let mm = now.toDateFormatter(dateFormat:"MM")
        let birthMM = self.toDateFormatter(dateFormat:"MM")
        
        let yearDiff = yy.toInt() - birthYY.toInt()
        let monthDiff = mm.toInt() - birthMM.toInt()
        let diff = (yearDiff * 12) + monthDiff
        
        let age = floor(Double(diff/12)).toInt()
        if isKr {
            return (age + 1).description + trailing
        } else {
            let md = now.toDateFormatter(dateFormat:"MMdd")
            let birthMD = self.toDateFormatter(dateFormat:"MMdd")
            if age > 0 {
                let unit = age != 1 ? trailing : trailing.replace("s", with: "")
                return age.description + unit 
            } else {
            
                let unit = diff != 1 ? subTrailing : subTrailing.replace("s", with: "")
                return diff.description + unit
            }
            
        }
    }
}

