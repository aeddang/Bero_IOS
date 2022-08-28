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
    func select(isShowing: Binding<Bool>,
               index: Binding<Int>,
               buttons:[SelectBtnData],
               cancel: @escaping () -> Void,
               action: @escaping (_ idx:Int) -> Void) -> some View {
        
        return Select(
            isShowing: isShowing,
            index: index,
            presenting: { self },
            buttons: buttons,
            cancel: cancel,
            action:action)
    }
    
}
struct SelectBtnData:Identifiable, Equatable{
    let id = UUID.init()
    let title:String
    let index:Int
    var tip:String? = nil
    var icon:String? = nil
}

struct Select<Presenting>: View where Presenting: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @Binding var isShowing: Bool
    @Binding var index: Int
    let presenting: () -> Presenting
    var buttons: [SelectBtnData]
    var cancel:() -> Void
    let action: (_ idx:Int) -> Void
    
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
                VStack{
                    Spacer()
                    VStack(alignment: .center, spacing:Dimen.margin.tiny) {
                        ForEach(self.buttons) { btn in
                            SelectButton(
                                icon:btn.icon,
                                text: btn.title ,
                                description: btn.tip,
                                index: btn.index,
                                isSelected: btn.index == self.index){idx in
                            
                                self.index = idx
                                self.action(idx)
                            }
                        }
                    }
                    .padding(.bottom, self.safeAreaBottom)
                    .modifier(BottomFunctionTab())
                    .padding(.bottom, self.isShowing ? 0 : -300)
                }
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
struct Select_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            Spacer()
        }
        .select(
            isShowing: .constant(true),
            index: .constant(0),
            buttons: [
                SelectBtnData(title:"test", index: 0) ,
                SelectBtnData(title:"test1", index: 1)
            ],
            cancel: {
                
            }
        ){ idx in
        
        }
        .environmentObject(PageSceneObserver())
    }
}
#endif
