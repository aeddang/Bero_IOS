//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import Foundation
import SwiftUI
import Combine

enum SceneSheet {
    case confirm(String?, String?, image:String?=nil, point:Int? = nil, exp:Double? = nil, (Bool) -> Void),
         select(String?, String?, image:String?=nil, point:Int? = nil, exp:Double? = nil, [String], (Int) -> Void),
         alert(String?, String?, image:String?=nil, point:Int? = nil, exp:Double? = nil, confirm:String? = nil, (() -> Void)? = nil)
}

enum SceneSheetResult {
    case complete(SceneSheet)
}


struct SceneSheetController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    
    @State var isShow = false
    @State var title:String? = nil
    @State var description:String? = nil
    @State var image:String? = nil
    @State var point:Int? = nil
    @State var exp:Double? = nil
    @State var buttons:[SheetBtnData] = []
    @State var isLock:Bool = false
    @State var currentSheet:SceneSheet? = nil
    @State var delayReset:AnyCancellable? = nil
    var body: some View {
        Form{
            Spacer()
        }
        .sheet(
            isShowing: self.$isShow,
            title: self.title,
            description: self.description,
            image: self.image,
            point: self.point,
            exp: self.exp,
            buttons: self.buttons,
            isLock: self.isLock,
            cancel: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.reset()
                }
            }
        ){ idx in
            switch self.currentSheet {
            case .alert(_, _, _, _, _, _, let completionHandler) :
                if let handler = completionHandler { self.selectedAlert(idx, completionHandler:handler) }
            case .select(_, _, _, _, _, _, let completionHandler) : self.selectedSelect(idx, completionHandler:completionHandler)
            case .confirm(_, _, _, _, _, let completionHandler) : self.selectedConfirm(idx, completionHandler:completionHandler)
            default: return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        
        }
        .onReceive(self.appSceneObserver.$sheet){ sheet in
            self.reset()
            self.currentSheet = sheet
            switch sheet{
            case .alert(let title,let text, let image, let point, let exp, let btnText, _) :
                self.setupAlert(title:title, text:text, image:image, point:point, exp:exp, btnText:btnText)
            case .select(let title,let text, let image, let point, let exp, let selects, _) :
                self.setupSelect(title: title, text: text, image:image, point:point, exp:exp, selects: selects)
            case .confirm(let title,let text,let image, let point, let exp,  _) :
                self.setupConfirm(title:title, text:text, image:image, point:point, exp:exp)
            default: return
            }
            withAnimation{
                self.isShow = true
            }
        }
    }//body
    
    func reset(){
        if self.isShow { return }
        self.title = nil
        self.image = nil
        self.point = nil
        self.exp = nil
        self.description = nil
        self.buttons = []
        self.currentSheet = nil
        self.isLock = false
    }

    
    func setupConfirm(title:String?, text:String?, image:String?, point:Int? = nil, exp:Double? = nil) {
        self.title = title
        self.image = image
        self.point = point
        self.exp = exp
        self.description = text
        self.isLock = true
        self.buttons = [
            SheetBtnData(title: String.app.cancel, index: 0),
            SheetBtnData(title: String.app.confirm, index: 1)
        ]
    }
    func selectedConfirm(_ idx:Int,  completionHandler: @escaping (Bool) -> Void) {
        completionHandler(idx == 1)
    }
    
    func setupAlert(title:String?, text:String?, image:String?, point:Int? = nil, exp:Double? = nil, btnText:String? = nil) {
        self.title = title
        self.description = text
        self.image = image
        self.point = point
        self.exp = exp
        self.isLock = true
        self.buttons = [
            SheetBtnData(title: btnText ?? String.app.confirm, index: 1)
        ]
    }
    func selectedAlert(_ idx:Int, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    
    func setupSelect(title:String?, text:String?, image:String?, point:Int? = nil, exp:Double? = nil, selects:[String] ) {
        self.title = title
        self.description = text
        self.image = image
        self.point = point
        self.exp = exp
        self.isLock = false
        self.buttons = zip(selects, 0..<selects.count).map{title, idx in
            SheetBtnData(title: title, index: idx)
        }
    }
    func selectedSelect(_ idx:Int, completionHandler: @escaping (Int) -> Void) {
        completionHandler(idx)
    }
}


