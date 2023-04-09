//
//  SystemEnvironment.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/08.
//

import Foundation
import UIKit

struct SystemEnvironment {
    static let model:String = AppUtil.model
    static let systemVersion:String = UIDevice.current.systemVersion
    static var firstLaunch :Bool = false
    static let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID.init().uuidString
    static let pushToken: String? = nil
    static var isTestMode:Bool = false
    static let isoCode = NSLocale.current.currencyCode?.uppercased() ?? ""
    static let preferredLang = NSLocale.preferredLanguages.first
    static var isTablet = AppUtil.isPad()
    static private(set) var breedCode:[String:String] = [:]
    static func setupBreedCode(res:ApiResultResponds){
        guard let datas = res.data as? [CodeData] else { return }
        self.setupBreedCode(datas: datas)
    }
    static func setupBreedCode(datas:[CodeData]){
        datas.forEach{ data in
            if let id = data.id?.description {
                self.breedCode[id] = data.value ?? "bero?"
            }
        }
    }
}



