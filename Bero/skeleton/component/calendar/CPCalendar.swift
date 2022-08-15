//
//  CPCalendar.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/14.
//

import Foundation
import SwiftUI




struct CPCalendar: PageComponent {
    enum DayStatus {
        case normal, today, selectAble , disable
    }
    @ObservedObject var viewModel:CalenderModel = CalenderModel()
    var weekString:[String] = ["S", "M", "T", "W", "T", "F", "S"]
    var body: some View {
        VStack( spacing: Dimen.margin.micro){
            HStack(spacing: 0){
                ImageButton(
                    defaultImage: Asset.icon.direction_left

                ){ _ in
                    self.prev()
                }
                .opacity(self.hasPrev ? 1 : 0.2)
                Text(self.currentMonth)
                    .modifier(BoldTextStyle(
                        size: Font.size.light ,color: Color.app.black))
                    .modifier(MatchHorizontal(height: Dimen.icon.light))
                ImageButton(
                    defaultImage:Asset.icon.direction_right
                ){ _ in
                    self.next()
                }
                .opacity(self.hasNext ? 1 : 0.2)
            }
            .padding(.bottom, Dimen.margin.tiny)
            HStack(spacing: 0){
                ForEach(self.weekString, id: \.self) { d in
                    Text(d)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin,color: Color.app.grey300))
                        .frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
                        .modifier(MatchHorizontal(height: Dimen.icon.medium))
                }
            }
            ForEach(self.weeks) { week in
                HStack(spacing: 0){
                    ForEach(week.days) { day in
                        if let title = day.date?.toDateFormatter(dateFormat: "dd").toInt().description {
                            switch day.status {
                            case .normal :
                                Text(title)
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,color: Color.app.grey400))
                                    .frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
                                    .modifier(MatchHorizontal(height: Dimen.icon.medium))
                            case .today :
                                Button(action: {
                                    guard let date = day.date else {return}
                                    self.selected(date:date)
                                }) {
                                    Text(title)
                                        .modifier(RegularTextStyle(
                                            size: Font.size.thin,
                                            color:  Color.app.white ))
                                        .frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
                                        .background( self.select == day.yyyyMMdd ? Color.brand.primary : Color.brand.secondary)
                                        .clipShape(Circle())
                                        .modifier(MatchHorizontal(height: Dimen.icon.medium))
                                }
                            case .selectAble :
                                Button(action: {
                                    guard let date = day.date else {return}
                                    self.selected(date:date)
                                }) {
                                    Text(title)
                                        .modifier(RegularTextStyle(
                                            size: Font.size.thin,
                                            color: self.select == day.yyyyMMdd ? Color.app.white : Color.brand.primary))
                                        .frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
                                        .background( self.select == day.yyyyMMdd ? Color.brand.primary : Color.app.orangeSub)
                                        .clipShape(Circle())
                                        .modifier(MatchHorizontal(height: Dimen.icon.medium))
                                }
                            case .disable :
                                Text(title)
                                    .modifier(RegularTextStyle(
                                        size: Font.size.thin,color: Color.app.grey200))
                                    .frame(width: Dimen.icon.medium, height: Dimen.icon.medium)
                                    .modifier(MatchHorizontal(height: Dimen.icon.medium))
                            }
                        }
                    }
                }
            }
        }
        .onReceive(self.viewModel.$request){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .reset(let yyyyMM) : self.reset(yyyyMM: yyyyMM)
            case .nextMonth : self.next()
            case .prevMonth : self.prev()
            case .selectDate(let date):
                self.selected(date:date)
                return
            }
        }
        
        .onAppear{
            withAnimation{ self.select = self.viewModel.select }
            self.yyyy = self.viewModel.select.toDate(dateFormat: "yyyyMMdd")?.toDateFormatter(dateFormat:"yyyy").toInt() ?? 2022
            self.mm = self.viewModel.select.toDate(dateFormat: "yyyyMMdd")?.toDateFormatter(dateFormat:"MM").toInt() ?? 1
            self.update()
        }
    }
    
    @State var yyyy:Int = 0 //Date().toDateFormatter(dateFormat:"yyyy").toInt()
    @State var mm:Int = 0 //Date().toDateFormatter(dateFormat:"MM").toInt()
    @State var currentMonth:String = ""
    @State var days:[DayData] = []
    @State var weeks:[WeekData] = []
    @State var select:String? = nil
    @State var hasNext:Bool = true
    @State var hasPrev:Bool = true
    private func selected(date:Date){
        let yyyyMMdd = date.toDateFormatter(dateFormat: "yyyyMMdd")
        withAnimation{ self.select = yyyyMMdd }
        self.viewModel.event = .selectdDate(date)
    }
    private func reset(yyyyMM:String? = nil){
        if let yyyyMM = yyyyMM {
            if yyyyMM.count != 6 {return}
            self.yyyy = yyyyMM.subString(start: 0, len: 4).toInt()
            self.mm = yyyyMM.subString(start: 4, len: 2).toInt()
            
        } else {
            self.yyyy = Date().toDateFormatter(dateFormat:"yyyy").toInt()
            self.mm = Date().toDateFormatter(dateFormat:"MM").toInt()
        }
        self.update()
    }
    private func next(){
        if !self.hasNext {return}
        let willMM = self.mm + 1
        if willMM > 12 {
            self.mm = 1
            self.yyyy += 1
        } else {
            self.mm = willMM
        }
        self.update()
    }
    private func prev(){
        if !self.hasPrev {return}
        let willMM = self.mm - 1
        if willMM < 1 {
            self.mm = 12
            self.yyyy -= 1
        } else {
            self.mm = willMM
        }
        self.update()
    }
    private func update(){
        let nowDate = AppUtil.networkTimeDate()
        let startDateComponents = DateComponents(year: self.yyyy, month: self.mm)
        let calendar = Calendar.current
        let startDate = calendar.date(from: startDateComponents)!
        let startDay = calendar.dateComponents([.weekday], from: startDate.noon).weekday ?? 0
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        let numDays = range.count
        
        var prevDates:[DayData] = []
        if startDay <= 7 && startDay > 1 {
            let prev = 1...(startDay-1)
            prevDates = prev.map{ num in
                let date = Calendar.current.date(byAdding: .day, value: -num, to: startDate.noon)
                let yyyyMMdd = date?.toDateFormatter(dateFormat: "yyyyMMdd") ?? ""
                return DayData(yyyyMMdd:yyyyMMdd, date: date, status: .disable)
            }.reversed()
        }
        let monthDate = startDate
        let current = 0...(numDays-1)
        let selectAble = self.viewModel.selectAbleDate
        let now = nowDate.toDateFormatter(dateFormat: "yyyyMMdd")
        let currentDates:[DayData] = current.map{ num in
            let date = Calendar.current.date(byAdding: .day, value: num, to: monthDate.noon)
            let yyyyMMdd = date?.toDateFormatter(dateFormat: "yyyyMMdd") ?? ""
            return DayData(yyyyMMdd: yyyyMMdd, date: date,
                           status:  yyyyMMdd == now
                           ? .today
                           : selectAble.first(where: {$0==yyyyMMdd}) != nil ? .selectAble : .normal  )
        }
        
        guard let endDate = currentDates.last?.date else {return}
        var nextDates:[DayData] = []
        let endDay = calendar.dateComponents([.weekday], from: endDate).weekday ?? 0
        if endDay < 7 && endDay >= 1 {
            let next = 1...(7-endDay)
            nextDates = next.map{ num in
                let date = Calendar.current.date(byAdding: .day, value: num, to: endDate.noon)
                let yyyyMMdd = date?.toDateFormatter(dateFormat: "yyyyMMdd") ?? ""
                return DayData(yyyyMMdd:yyyyMMdd, date: date, status: .disable)
            }
        }
        prevDates.append(contentsOf:currentDates)
        prevDates.append(contentsOf: nextDates)
        self.days = prevDates
        
        let count:Int = 7
        var rows:[WeekData] = []
        var cells:[DayData] = []
        var total = prevDates.count
        prevDates.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append( WeekData(days:cells) )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                WeekData(days:cells)
            )
        }
        self.weeks = rows
        self.currentMonth = monthDate.toDateFormatter(dateFormat: "MMMM, yyyy")
        self.viewModel.event = .changedMonth(date: monthDate)
        let nowValue = nowDate.toDateFormatter(dateFormat:"yyyyMM").toInt()
        let currentValue = monthDate.toDateFormatter(dateFormat:"yyyyMM").toInt()
        self.hasNext = nowValue > currentValue
    }
    
}
struct WeekData:Identifiable {
    let id = UUID().uuidString
    let days:[DayData]
}

struct DayData:Identifiable {
    let id = UUID().uuidString
    let yyyyMMdd:String
    let date:Date?
    let status:CPCalendar.DayStatus
}

#if DEBUG
struct CPCalendar_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPCalendar().contentBody
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif
