//
//  TitleTab.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/20.
//

//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI




struct SelectDateStep: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    let profile:ModifyPetProfileData?
    let step:PageAddDog.Step
    let prev: (() -> Void)
    let next: ((ModifyPetProfileData) -> Void)
    
    var dateClosedRange: ClosedRange<Date> {
        let startDay = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let now = Date()
        return startDay...now
    }
    @State var selectDate:Date = Date()
    @State var isShowing = false
    var body: some View {
        VStack(spacing: Dimen.margin.tiny){
            Spacer()
            VStack(spacing:Dimen.margin.medium){
                DatePicker(
                    "",
                    selection: self.$selectDate,
                    in:self.dateClosedRange,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .exChangeTextColor(Color.brand.primary)
                .datePickerStyle(WheelDatePickerStyle())
                
                SortButton(
                    type: .strokeFill,
                    sizeType: .small,
                    text: self.selectDate.toAge(),
                    color: Color.app.orange,
                    isSort: false,
                    isSelected: true
                ){
                    self.selectDate = Date()
                }
            }
            Spacer()
            HStack (spacing:Dimen.margin.tinyExtra){
                if !self.step.isFirst {
                    FillButton(
                        type: .fill,
                        text: String.button.goBack,
                        color: Color.app.grey50,
                        textColor: Color.app.grey400
                    ){_ in
                        self.prev()
                    }
                }
                FillButton(
                    type: .fill,
                    text: String.button.next,
                    color:Color.app.white,
                    gradient: Color.app.orangeGradient
                ){_ in
                    self.next(
                        .init(
                            birth:self.selectDate
                        )
                    )
                }
                .modifier(Shadow())
            }
        }
        .opacity(self.isShowing ? 1 : 0)
        .onAppear{
            self.selectDate = self.profile?.birth ?? Date()
            withAnimation{  self.isShowing = true }
        }
    }
}

#if DEBUG
struct SelectDateStep_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectDateStep(
                profile: .init(),
                step: .birth,
                prev: {},
                next: { data in }
            )
            .environmentObject(PagePresenter()).frame(width:320,height:600)
                
        }
    }
}
#endif

