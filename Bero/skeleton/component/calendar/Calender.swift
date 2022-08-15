//
//  Calender.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/14.
//

import Foundation
open class CalenderModel: ComponentObservable {
    @Published var event:CalenderEvent? = nil
    @Published var request:CalenderRequest? = nil
    var selectAbleDate:[String] = []
    var select:String = AppUtil.networkTimeDate().toDateFormatter(dateFormat:"yyyyMMdd")
}
enum CalenderRequest {
    case reset(String? = nil), nextMonth, prevMonth, selectDate(Date)
}
enum CalenderEvent {
    case changedMonth(date:Date), selectdDate(Date)
}
