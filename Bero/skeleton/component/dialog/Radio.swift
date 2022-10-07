//
//  Toast.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/28.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI


extension View {
    func radio(isShowing: Binding<Bool>,
               buttons:[String],
               title:String? = nil,
               description:String? = nil,
               isMultiSelectAble:Bool = false,
               action: @escaping (_ idx:Int, _ isSelect:Bool) -> Void,
               cancel: @escaping () -> Void,
               completed: @escaping () -> Void
    ) -> some View {
        
        let range = 0 ..< buttons.count
        return Radio(
            isShowing: isShowing,
            buttons:.constant(
                zip(range,buttons).map {index, text in
                    RadioBtnData(title: text, index: index)
            }),
            title:title,
            description:description,
            isMultiSelectAble:isMultiSelectAble,
            presenting: { self },
            action:action,
            cancel:cancel,
            completed: completed
        )
    }
    func radio(isShowing: Binding<Bool>,
               buttons:Binding<[RadioBtnData]>,
               title:String? = nil,
               description:String? = nil,
               isMultiSelectAble:Bool = false,
               action: @escaping (_ idx:Int, _ isSelect:Bool) -> Void,
               cancel: @escaping () -> Void,
               completed: @escaping () -> Void
    ) -> some View {
        
       return Radio(
            isShowing: isShowing,
            buttons:buttons,
            title:title,
            description:description,
            isMultiSelectAble:isMultiSelectAble,
            presenting: { self },
            action:action,
            cancel:cancel,
            completed: completed
       )
    }
}
class RadioBtnData:Identifiable{
    let id = UUID.init()
    let icon:String?
    let title:String
    var value:String? = nil
    var index:Int
    var isSelected:Bool
    init(
        icon:String? = nil,
        title:String,
        value:String? = nil,
        index:Int,
        isSelected:Bool = false
    ){
        self.icon = icon
        self.title = title
        self.value = value
        self.index = index
        self.isSelected = isSelected
    }
}

struct Radio<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    @Binding var buttons: [RadioBtnData]
    var title:String? = nil
    var description:String? = nil
    var isMultiSelectAble:Bool = false
    let presenting: () -> Presenting
    var action: (_ idx:Int, _ isSelect:Bool ) -> Void
    var cancel:() -> Void
    var completed:() -> Void
    @State var safeAreaBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Button(action: {
                    withAnimation{
                        self.isShowing = false
                    }
                    self.cancel()
                }) {
                   Spacer().modifier(MatchParent())
                       .background(Color.transparent.black70)
                       .opacity(self.pageOpacity)
                }
                VStack( spacing: Dimen.margin.medium){
                    VStack(alignment: .leading, spacing: Dimen.margin.tinyExtra){
                        HStack(spacing:0){
                            if let title = self.title {
                                Text(title)
                                    .modifier(BoldTextStyle(
                                        size: Font.size.medium,
                                        color: Color.app.black
                                    ))
                            }
                            Spacer().modifier(MatchHorizontal(height: 0))
                            ImageButton(defaultImage: Asset.icon.close){ _ in
                                self.cancel()
                            }
                        }
                        if let description = self.description {
                            Text(description)
                                .modifier(RegularTextStyle(
                                    size: Font.size.thin,
                                    color: Color.app.grey400
                                ))
                        }
                        
                    }
                    if self.buttons.count < 10 {
                        VStack (alignment: .leading, spacing: Dimen.margin.tiny){
                            ForEach(self.buttons) { btn in
                                RadioButton(
                                    type: .blank,
                                    isChecked: btn.isSelected,
                                    icon: btn.icon,
                                    text: btn.title
                                ){isSelect in
                                    self.update(btn: btn, isSelect: isSelect)
                                }
                            }
                        }
                    }else {
                        ScrollView(.vertical , showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: Dimen.margin.tiny){
                                ForEach(self.buttons) { btn in
                                    RadioButton(
                                        type: .blank,
                                        isChecked: btn.isSelected,
                                        text: btn.title
                                    ){isSelect in
                                        self.update(btn: btn, isSelect: isSelect)
                                    }
                                }
                            }
                        }
                        .frame(height:300)
                    }
                    if self.isMultiSelectAble {
                        HStack(spacing: Dimen.margin.tinyExtra){
                            FillButton(type: .fill,
                                       text: String.button.reset,
                                       color:Color.app.grey50,
                                       textColor: Color.app.grey400){ _ in
                                self.buttons.forEach{$0.isSelected = false}
                            }
                            FillButton(type: .fill, text: String.button.apply,
                                       color: self.buttons.first(where: {$0.isSelected}) == nil
                                       ? Color.app.grey400 : Color.app.grey50,
                                       gradient: self.buttons.first(where: {$0.isSelected}) == nil
                                       ? nil : Color.app.orangeGradient){ _ in
                                
                                if self.buttons.first(where: {$0.isSelected}) == nil {return}
                                self.completed()
                            }
                        }
                    }
                }
                .padding(.bottom, self.safeAreaBottom)
                .modifier(BottomFunctionTab())
                .padding(.bottom, self.isShowing ? 0 : -300)
                .offset(self.dragAmount)
            }
            .opacity(self.isShowing ? 1 : 0)
            .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
                withAnimation{
                    self.safeAreaBottom = pos
                }
            }
            .highPriorityGesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .global)
                    .onChanged({ value in self.drag(value: value, screenHeight: geometry.size.height)})
                    .onEnded({ value in self.dragCompleted(value: value, screenHeight: geometry.size.height)})
            )
            .gesture(
                PageDragingModel.cancelGesture
                    .onChanged({_ in self.dragCancel()})
                    .onEnded({_ in self.dragCancel()})
            )
        }
    }
    
    @State var selected = false
    @State var selects:[Int] = []
    private func update(btn:RadioBtnData, isSelect:Bool) {
        let newButtons = self.buttons
        self.buttons = []
        self.action(btn.index, isSelect)
        if self.isMultiSelectAble {
            btn.isSelected = isSelect
            self.buttons = newButtons
        }else {
            if isSelect {
                if let find = newButtons.first(where: {$0.isSelected}) {
                    find.isSelected = false
                }
                btn.isSelected = true
            } else {
                btn.isSelected = false
            }
            self.buttons = newButtons
            DispatchQueue.main.asyncAfter(deadline: .now()+0.35){
                self.completed()
            }
        }
        
    }
    
    @State var pageOpacity:Double = 1
    @State var dragAmount = CGSize.zero
    private func drag(value:DragGesture.Value, screenHeight:CGFloat){
        let offset = value.translation.height
        
        withAnimation(.easeOut(duration: PageContentBody.pageMoveDuration)){
            self.dragAmount = CGSize(width: 0, height: max(0,offset))
            self.pageOpacity = (screenHeight-offset)/screenHeight
        }
    }
    private func dragCompleted(value:DragGesture.Value, screenHeight:CGFloat){
        if value.predictedEndTranslation.height > screenHeight/3 {
            withAnimation(.easeOut(duration: PageContentBody.pageMoveDuration)){
                self.isShowing = false
            }
            self.cancel()
            self.dragCancel()
            
        } else {
            self.dragCancel()
        }
    }
    private func dragCancel(){
        withAnimation(.easeOut(duration: 0.3)){
            self.dragAmount = CGSize.zero
            self.pageOpacity = 1
        }
    }
    
}
#if DEBUG
struct Radio_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .radio(
            isShowing: .constant(true),
            buttons: [
                "test","test1"
            ],
            action: { idx, isSelect in
                
            },
            cancel: {
                
            },
            completed: {
            
            }
        )
        .environmentObject(PageSceneObserver())
    }
}
#endif

