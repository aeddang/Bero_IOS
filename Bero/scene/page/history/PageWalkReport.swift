//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

class ReportData {
    private(set) var daysWalkData:ArcGraphData = ArcGraphData()
    private(set) var daysWalkReport:String = ""
    private(set) var daysWalkCompareData:[CompareGraphData] = []
    private(set) var daysWalkCompareReport:String = ""
    private(set) var daysWalkTimeData:LineGraphData = LineGraphData()
    private(set) var currentDaysWalkTimeIdx:Int = 0
    private(set) var daysWalkTimeReport:String = ""
    
    
    func setupData(_ data:MissionReport){
        self.daysWalkReport = Int(daysWalkData.value).description + " " + String.pageText.reportWalkDayUnit
        if daysWalkCompareData.count >= 2 {
            let me = daysWalkCompareData.first!.value
            let other = daysWalkCompareData.last!.value
            let diff = me - other
            if diff > 0 {
                self.daysWalkCompareReport = Double(diff).toTruncateDecimal(n:2) + String.pageText.reportWalkDayUnit + " " + String.pageText.reportWalkDayCompareMore
            } else if diff < 0 {
                self.daysWalkCompareReport = Double(abs(diff)).toTruncateDecimal(n:2) + String.pageText.reportWalkDayUnit + " " + String.pageText.reportWalkDayCompareLess
            } else {
                self.daysWalkCompareReport = String.pageText.reportWalkDayCompareSame
            }
        }
        var avg:Float = 0
        if let missionTimes = data.missionTimes {
            let values:[Float] = missionTimes.map{ time in
                return Float(time.v ?? 0)
            }
            avg = values.reduce(Float(0), {$0 + $1}) / Float(self.daysWalkTimeData.values.count)
        }
        self.daysWalkTimeReport = Double(avg).toTruncateDecimal(n:2) + " " + String.pageText.reportWalkRecentlyUnit
    }
    func setWeeklyData(_ data:MissionSummary) -> ReportData{
        if let report = data.weeklyReport {
            self.currentDaysWalkTimeIdx = self.setReport(report)
            self.setupData(report)
        }
       
        return self
    }
    func setMonthlyData(_ data:MissionSummary) -> ReportData{
        if let report = data.monthlyReport {
            self.currentDaysWalkTimeIdx = self.setReport(report)
            self.setupData(report)
        }
        return self
    }
    
    func setReport(_ data:MissionReport)-> Int{
        
        var todayIdx:Int = -1
        let max = Float(data.missionTimes?.count ?? 7)
        let myCount =  Float(data.totalMissionCount ?? 0)
        self.daysWalkCompareData
        = [
            CompareGraphData(
                value:myCount, max:max ,
                color:Color.brand.primary,
                title:String.pageText.reportWalkDayCompareMe),
            CompareGraphData(
                value:Float(data.avgMissionCount ?? 0), max:max,
                color:Color.app.grey300,
                title:String.pageText.reportWalkDayCompareOthers)
        ]
        if let missionTimes = data.missionTimes {
            let count = missionTimes.count
            self.daysWalkData = ArcGraphData(value: myCount, max: Float(count))
            let today = Date().toDateFormatter(dateFormat: "yyyyMMdd")
            let values:[Float] = missionTimes.map{ time in
                return Float(min(50, time.v ?? 0)) / 50
            }
            let lines:[String] = zip(0...missionTimes.count,missionTimes).map{idx, time in
                if time.d == today { todayIdx = idx }
                let date = time.d?.toDate(dateFormat: "yyyyMMdd") ?? Date()
                let mm = date.toDateFormatter(dateFormat: "MM").toInt().description
                let dd = date.toDateFormatter(dateFormat: "dd").toInt().description
                return mm + "/" + dd
            }
            self.daysWalkTimeData = LineGraphData(values: values, lines: lines)
            
        }
        return todayIdx
    }
    
}

extension PageWalkReport{
    enum ReportType{
        case weekly, monthly
    }
}

struct PageWalkReport: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var infinityScrollModel:InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
   
    
    @State var selectedMenu:Int = 0
   
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(alignment: .topLeading){
                    VStack(spacing:0){
                        TitleTab(
                            useBack: true
                        ){ type in
                            switch type {
                            case .back : self.pagePresenter.closePopup(self.pageObject?.id)
                            default : break
                            }
                        }
                        .padding(.horizontal, Dimen.app.pageHorinzontal)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            axes: .vertical,
                            showIndicators : false,
                            marginVertical: Dimen.margin.medium,
                            marginHorizontal: Dimen.app.pageHorinzontal,
                            spacing:Dimen.margin.medium,
                            isRecycle: true,
                            useTracking: true
                        ){
                            HStack(spacing: Dimen.margin.thin){
                                TitleSection(
                                    title: String.pageTitle.walkReport
                                )
                                SortButton(
                                    type: .stroke,
                                    sizeType: .big,
                                    userProgile: nil,
                                    petProgile: self.profile,
                                    text: self.profile?.name ?? "",
                                    color:Color.app.grey400,
                                    isSort: true){
                                        self.onSort()
                                    }
                                    .fixedSize()
                            }
                            if let profile = self.profile {
                                PetWalkPropertySection(profile: profile)
                            } else {
                                PetWalkPropertySection(profile: PetProfile())
                            }
                            Spacer().modifier(LineHorizontal())
                            MenuTab(
                                pageObservable:self.pageObservable,
                                viewModel:self.navigationModel,
                                buttons: [
                                    String.pageText.reportWalkSummaryWeekly, String.pageText.reportWalkSummaryMonthly
                                ],
                                selectedIdx: self.selectedMenu
                            )
                            .onReceive(self.navigationModel.$index){ idx in
                                self.selectedMenu = idx
                                self.load()
                            }
                            if let data = self.reportData {
                                VStack(alignment: .leading, spacing: Dimen.margin.mediumUltra){
                                    VStack(alignment: .center, spacing: Dimen.margin.regular){
                                        ReportText(
                                            leading: String.pageText.reportWalkDayText,
                                            value: data.daysWalkReport,
                                            trailing: self.reportType == .weekly ? String.pageText.reportWalkDayWeek : String.pageText.reportWalkDayMonth)
                                        ArcGraph(data: data.daysWalkData)
                                    }
                                    Spacer().modifier(LineHorizontal())
                                    VStack(alignment: .leading, spacing: Dimen.margin.regular){
                                        ReportText(
                                            leading: String.pageText.reportWalkDayCompareText1,
                                            value: data.daysWalkCompareReport,
                                            trailing: String.pageText.reportWalkDayCompareText2)
                                        CompareGraph(datas: data.daysWalkCompareData)
                                    }
                                    Spacer().modifier(LineHorizontal())
                                    VStack(alignment: .leading, spacing: Dimen.margin.regular){
                                        ReportText(
                                            leading: String.pageText.reportWalkRecentlyText1,
                                            value: data.daysWalkTimeReport,
                                            trailing: String.pageText.reportWalkRecentlyText2)
                                        LineGraph(selectIdx: data.currentDaysWalkTimeIdx, data: data.daysWalkTimeData)
                                        Text(String.pageText.reportWalkRecentlyTip)
                                            .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.grey400))
                                    }
                                }
                            } else {
                                Spacer()
                            }
                        }
                    }
                    
                }
                .modifier(PageVertical())
                .background(Color.brand.bg)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                
            }
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                switch res.type {
                case .getMissionSummary(let id) :
                    if self.profile?.petId == id {
                        self.loaded(res)
                    }
                case .getUserDetail(let userId):
                    if userId == self.userId , let data = res.data as? UserData{
                        self.user = User().setData(data:data)
                        self.profile = self.user?.pets.first
                        self.load()
                        self.pageObservable.isInit = true
                    }
                default : break
                }
            }
            .onReceive(self.dataProvider.$error){err in
                guard let err = err else { return }
                if !err.id.hasPrefix(self.tag) {return}
                switch err.type {
                case .getUserDetail:
                    self.pageObservable.isInit = true
                default : break
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let user = obj.getParamValue(key: .data) as? User{
                    self.user = user
                    self.userId = user.snsUser?.snsID
                    if let profile = obj.getParamValue(key: .subData) as? PetProfile{
                        self.profile = profile
                    } else {
                        self.profile = self.user?.currentPet ?? self.user?.pets.first
                    }
                    self.load()
                    self.pageObservable.isInit = true
                    return
                }
                if let userId = obj.getParamValue(key: .id) as? String{
                    self.userId = userId
                    self.dataProvider.requestData(q: .init(id:self.tag, type: .getUserDetail(userId:userId)))
                }
            }
        }//geo
    }//body
    @State var userId:String? = nil
    @State var user:User? = nil
    @State var profile:PetProfile? = nil
    
    
    @State var reportType:ReportType = .weekly
    @State var reportData:ReportData? = nil
    
    func load(){
        self.reportData = nil
        self.reportType = self.selectedMenu == 0 ? .weekly : .monthly
        self.dataProvider.requestData(q: .init(type: .getMissionSummary(petId: self.profile?.petId ?? 0)))
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? MissionSummary else { return }
        self.setupReportData(data)
    }
    
    func setupReportData(_ data:MissionSummary){
        switch self.reportType {
        case .monthly :
            self.reportData = ReportData().setMonthlyData(data)
        case .weekly :
            self.reportData = ReportData().setWeeklyData(data)
        }
    }
    
    private func onSort(){
        guard let user = self.user else {return}
        let datas:[String] = user.pets.map{$0.name ?? ""}
        self.appSceneObserver.radio = .sort( (self.tag, datas), title: String.pageText.walkHistorySeletReport){ idx in
            guard let idx = idx else {return}
            self.profile = nil
            let select = datas[idx]
            DispatchQueue.main.async {
                self.profile = user.pets.first(where: {$0.name == select})
                self.load()
            }
            
        }
    }
}


#if DEBUG
struct PageReport_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageWalkReport().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

