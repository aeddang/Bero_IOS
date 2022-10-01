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

struct SelectDateEdit: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    var prevData:Date = Date()
    let type:PageEditProfile.EditType
    let edit: ((PageEditProfile.EditData) -> Void)
    
    var dateClosedRange: ClosedRange<Date> {
        let startDay = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let now = Date()
        return startDay...now
    }
    @State var selectDate:Date = Date()
    var body: some View {
        VStack(alignment: .leading, spacing: Dimen.margin.heavy){
            if let caption = self.type.caption {
                Text(caption)
                    .modifier(SemiBoldTextStyle(size: Font.size.medium,color: Color.app.black))
                    .lineLimit(1)
                    .padding(.top, Dimen.margin.regularUltra)
            }
            VStack(spacing:0){
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
                    text: self.selectDate.toDateFormatter(dateFormat: "EEEE, MMMM d, yyyy"),
                    color: Color.app.orange,
                    isSort: false,
                    isSelected: true
                ){
                    self.selectDate = Date()
                }
                .padding(.top, Dimen.margin.medium)
                Spacer().modifier(MatchHorizontal(height: 0))
            }
            FillButton(
                type: .fill,
                text: String.button.save,
                color: Color.app.white,
                gradient: Color.app.orangeGradient
            ){_ in
                self.onAction()
            }
            .modifier(Shadow())
            .opacity(self.selectDate == self.prevData ? 0.3 : 1)
            Spacer().modifier(MatchParent())
        }
        .onAppear{
            self.selectDate = self.prevData
        }
    }
    
    private func onAction(){
        if self.selectDate == self.prevData {return}
        self.edit(.init(birth:self.selectDate))
    }
}

#if DEBUG
struct SelectDateEdit_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectDateEdit(
                type: .birth,
                edit: { data in }
            )
            .environmentObject(PagePresenter()).frame(width:320,height:600)
                
        }
    }
}
#endif

