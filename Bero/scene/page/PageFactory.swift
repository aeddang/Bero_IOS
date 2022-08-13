//
//  PageFactory.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import UIKit
import Foundation
import SwiftUI

extension PageID{
    static let intro:PageID = "intro"
    static let login:PageID = "login"
    static let walk:PageID = "walk"
    static let matching:PageID = "matching"
    static let diary:PageID = "diary"
    static let my:PageID = "my"
    
    static let addDog:PageID = "addDog"
    static let addDogCompleted:PageID = "addDogCompleted"
}

struct PageProvider {
    
    static func getPageObject(_ pageID:PageID)-> PageObject {
        let pobj = PageObject(pageID: pageID)
        pobj.pageIDX = getPageIdx(pageID)
        pobj.isHome = isHome(pageID)
        pobj.isAnimation = !pobj.isHome
        pobj.isDimed = getDimed(pageID)
        pobj.animationType = getType(pageID)
        pobj.zIndex = isTop(pageID) ? 1 : 0
        return pobj
    }
    
    
    static func isHome(_ pageID:PageID)-> Bool{
        switch pageID {
        case .intro, .login, .walk, .matching, .diary, .my : return  true
           default : return  false
        }
    }
    
    static func getType(_ pageID:PageID)-> PageAnimationType{
        switch pageID {
        case  .addDog, .addDogCompleted : return .vertical
        //case  .missionCompleted : return .opacity
        default : return  .horizontal
        }
    }
    
    static func isTop(_ pageID:PageID)-> Bool{
        switch pageID{
        //case .mission : return true
        default : return  false
        }
    }
    
    static func getPageIdx(_ pageID:PageID)-> Int {
        switch pageID {
        case .intro : return 1
        case .walk : return 100
        case .matching : return 200
        case .diary : return 300
        case .my : return 400
        default : return  9999
        }
    }
    
    static func getDimed(_ pageID:PageID)-> Bool {
        switch pageID {
            default : return  false
        }
    }
    
    static func getPageTitle(_ pageID:PageID, deco:String = "")-> String {
        switch pageID {
            default : return  ""
        }
    }
}

extension PageParam {
    static let idx = "idx"
    static let id = "id"
    static let subId = "subId"
    static let link = "link"
    static let data = "data"
    static let datas = "datas"
    static let type = "type"
    static let subType = "subType"
    static let title = "title"
    static let text = "text"
    static let subText = "subText"
}

extension PageEventType {
    static let pageChange = "pageChange"
    static let completed = "completed"
    static let cancel = "cancel"
}

enum PageStyle{
    case dark, white, normal, primary
    var textColor:Color {
        get{
            switch self {
            case .normal: return Color.app.white
            case .dark: return Color.app.white
            case .primary: return Color.app.white
            case .white: return Color.app.grey100
            }
        }
    }
    var bgColor:Color {
        get{
            switch self {
            case .normal: return Color.brand.bg
            case .dark: return Color.app.grey100
            case .primary: return Color.brand.primary
            case .white: return Color.app.white
            }
        }
    }
}

struct PageFactory{
    static func getPage(_ pageObject:PageObject) -> PageViewProtocol{
        switch pageObject.pageID {
        case .intro : return PageIntro()
        case .login : return PageLogin()
        case .walk : return PageWalk()
        case .my : return PageLogin()
        case .addDog : return PageAddDog()
        case .addDogCompleted : return PageAddDogCompleted()
        default : return PageTest()
        }
    }
   
}

struct PageSceneModel: PageModel {
    var currentPageObject: PageObject? = nil
    var topPageObject: PageObject? = nil
    
    func getPageOrientation(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else { return UIInterfaceOrientationMask.all }
        switch pageObject.pageID {
        //case .picture :  return .all
        default :  return .portrait
        }
    }
    func getPageOrientationLock(_ pageObject:PageObject?) -> UIInterfaceOrientationMask? {
        guard let pageObject = pageObject ?? self.topPageObject else { return UIInterfaceOrientationMask.all }
        switch pageObject.pageID {
        //case .picture :  return .all
        default : return  .portrait
        }
    }
    func getUIStatusBarStyle(_ pageObject:PageObject?) -> UIStatusBarStyle? {
        guard let page = pageObject else {return .darkContent}
        switch page.pageID {
        //case .picture : return .lightContent
        default : return .darkContent
        }
    }
    func getCloseExceptions() -> [PageID]? {
        return []
    }
    
    func isHistoryPage(_ pageObject:PageObject ) -> Bool {
        switch pageObject.pageID {
        case .addDog, .addDogCompleted : return false
        default : return true
        }
    }
    
    static func needBottomTab(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .walk, .matching, .my, .diary : return true
        default : return false
        }
    }
    
    static func needKeyboard(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        // case .profileRegist , .profileModify: return true
        default : return true
        }
    }
    
}

