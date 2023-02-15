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
        let age = yy.toInt() - birthYY.toInt()
        if isKr {
            return (age + 1).description + trailing
        } else {
            let md = now.toDateFormatter(dateFormat:"MMdd")
            let birthMD = self.toDateFormatter(dateFormat:"MMdd")
            if age > 0 {
                let unit = age != 1 ? trailing : trailing.replace("s", with: "")
                return md < birthMD ?  age.description + unit : (age + 1).description + unit
            } else {
                let mm = now.toDateFormatter(dateFormat:"MM")
                let birthMM = self.toDateFormatter(dateFormat:"MM")
                let months = mm.toInt() - birthMM.toInt()
                let unit = months != 1 ? subTrailing : subTrailing.replace("s", with: "")
                return months.description + unit
            }
            
        }
    }
}

