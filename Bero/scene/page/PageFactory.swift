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
    static let explore:PageID = "explore"
    static let chat:PageID = "chat"
    static let matching:PageID = "matching"
    static let diary:PageID = "diary"
    static let my:PageID = "my"
    static let walkHistory:PageID = "walkHistory"
    static let walkReport:PageID = "walkReport"
    static let missionHistory:PageID = "missionHistory"
    static let myLv:PageID = "myLv"
    static let dog:PageID = "dog"
    static let user:PageID = "user"
    static let album:PageID = "album"
    static let manageDogs:PageID = "manageDogs"
    static let modifyUser:PageID = "modifyUser"
    static let modifyPet:PageID = "modifyPet"
    static let modifyPetHealth:PageID = "modifyPetHealth"

    static let editProfile:PageID = "editProfile"
    
    static let missionCompleted:PageID = "missionCompleted"
    static let walkCompleted:PageID = "walkCompleted"
    
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
        pobj.isAutoInit = isAutoInit(pageID)
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
        case  .missionCompleted, .walkCompleted: return .opacity
        default : return  .horizontal
        }
    }
    
    static func isTop(_ pageID:PageID)-> Bool{
        switch pageID{
        default : return  false
        }
    }
    
    static func isAutoInit(_ pageID:PageID)-> Bool{
        switch pageID{
        case .user, .album, .dog,.walkReport, .walkHistory, .missionHistory : return false
        default : return  true
        }
    }
    
    static func getPageIdx(_ pageID:PageID)-> Int {
        switch pageID {
        case .intro : return 1
        case .walk : return 100
        case .explore : return 200
        case .chat : return 300
        case .matching : return 400
        case .diary : return 500
        case .my : return 600
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
    static let subData = "subData"
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
    static func getPage(_ pageObject:PageObject, pageObservable:PageObservable) -> PageViewProtocol{
        switch pageObject.pageID {
        case .intro : return PageIntro(pageObservable:pageObservable)
        case .login : return PageLogin(pageObservable:pageObservable)
        case .walk : return PageWalk(pageObservable:pageObservable)
        case .explore : return PageExplore(pageObservable:pageObservable)
        case .chat : return PageWalk(pageObservable:pageObservable)
        case .my : return PageMy(pageObservable:pageObservable)
        case .dog : return PageDog(pageObservable:pageObservable)
        case .user : return PageUser(pageObservable:pageObservable)
        case .walkHistory : return PageWalkHistory(pageObservable:pageObservable)
        case .walkReport : return PageWalkReport(pageObservable:pageObservable)
        case .missionHistory : return PageMissionHistory(pageObservable:pageObservable)
        case .album : return PageAlbum(pageObservable:pageObservable)
        case .myLv : return PageMyLv(pageObservable:pageObservable)
        case .manageDogs : return PageManageDogs(pageObservable:pageObservable)
        case .addDog : return PageAddDog(pageObservable:pageObservable)
        case .addDogCompleted : return PageAddDogCompleted(pageObservable:pageObservable)
        case .missionCompleted : return PageMissionCompleted(pageObservable:pageObservable)
        case .walkCompleted : return PageWalkCompleted(pageObservable:pageObservable)
        case .modifyUser : return PageModifyUser(pageObservable:pageObservable)
        case .modifyPet : return PageModifyPet(pageObservable:pageObservable)
        case .modifyPetHealth : return PageModifyPetHealth(pageObservable:pageObservable)
        case .editProfile : return PageEditProfile(pageObservable:pageObservable)
        default : return PageTest(pageObservable:pageObservable)
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
        case .addDog, .addDogCompleted, .missionCompleted, .walkCompleted, .editProfile : return false
        default : return true
        }
    }
    
    static func needBottomTab(_ pageObject:PageObject) -> Bool{
        switch pageObject.pageID {
        case .walk, .matching, .my, .diary, .chat, .explore : return true
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

