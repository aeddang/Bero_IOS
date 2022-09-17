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
enum SceneRadio:Equatable {
    case sort((String,[String]),
              title:String?=nil,
              description:String?=nil,
              completed:(Int?) -> Void)
    
    case filter((String,[String]),
              title:String?=nil,
              description:String?=nil,
              completed:([Int]?) -> Void)
    
    
    func check(key:String)-> Bool{
           switch (self) {
           case .sort(let v, _, _, _): return v.0 == key
           case .filter(let v, _, _, _): return v.0 == key
           }
       }
    static func ==(lhs: SceneRadio, rhs: SceneRadio) -> Bool {
        switch (lhs, rhs) {
        case (.sort(let lh,  _, _, _), .sort(let rh,  _, _, _)): return lh.0 == rh.0
        case (.filter(let lh,  _, _, _), .filter(let rh,  _, _, _)): return lh.0 == rh.0
        default : return false
        }
    }
}
enum SceneRadioResult {
    case complete(SceneRadio,[Int]?)
}


struct SceneRadioController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:AppSceneObserver
    
    @State var isShow = false
    @State var title:String? = nil
    @State var description:String? = nil
    @State var isMultiSelectAble:Bool = false
    @State var buttons:[RadioBtnData] = []
    @State var currentRadio:SceneRadio? = nil
  
   
    var body: some View {
        Form{
            Spacer()
        }
        .radio(
            isShowing: self.$isShow,
            buttons: self.$buttons,
            title:self.title,
            description:self.description,
            isMultiSelectAble:self.isMultiSelectAble,
            action: { _ , _ in },
            cancel: {
                switch self.currentRadio {
                case .sort( _, _, _ , let completed) : completed( nil )
                case .filter( _, _, _ ,let  completed) : completed( nil )
                default: return
                }
                withAnimation{
                    self.isShow = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.reset()
                }
            },
            completed: {
                switch self.currentRadio {
                case .sort( _, _, _ , let completed) : completed( self.selectedRadio()?.first )
                case .filter( _, _, _ ,let  completed) : completed( self.selectedRadio() )
                default: return
                }
                withAnimation{
                    self.isShow = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.reset()
                }
            }
        )
            
        
        .onReceive(self.sceneObserver.$radio){ radio in
            self.currentRadio = radio
            switch radio{
            case .sort(let data,  let title, let description, _) :
                self.title = title
                self.description = description
                self.isMultiSelectAble = false
                self.setupButton(data: data)
            case .filter(let data,  let title, let description, _) :
                self.title = title
                self.description = description
                self.isMultiSelectAble = true
                self.setupButton(data: data)
            default: return
            }
            withAnimation{
                self.isShow = true
            }
        }
        
    }//body
    
    func reset(){
        if self.isShow { return }
        self.buttons = []
        self.currentRadio = nil
        self.title = nil
        self.description = nil
    }
    
    func setupButton(data:(String,[String])) {
        let range = 0 ..< data.1.count
        self.buttons = zip(range,data.1).map {index, text in
            RadioBtnData(title: text, index: index)
        }
    }
    
    func selectedRadio() -> [Int]? {
        let select:[Int] = self.buttons.filter{$0.isSelected}.map{$0.index}
        guard let radio = self.currentRadio else {return select}
        self.sceneObserver.radioResult = .complete(radio, select)
        return select
    }
    
   
}


