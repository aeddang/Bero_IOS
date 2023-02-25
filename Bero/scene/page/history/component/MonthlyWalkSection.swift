import Foundation
import SwiftUI

struct MonthlyWalkSection: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var calenderModel: CalenderModel = CalenderModel()
    var user:User
    var listSize:CGFloat = 300
    var body: some View {
        Text(self.currentDate)
            .modifier(MediumTextStyle(
                size: Font.size.thin,
                color: Color.brand.primary
            ))
            .onReceive(self.calenderModel.$event){evt in
                guard let evt = evt else { return }
                switch evt {
                case .selectdDate(let date) :
                    self.updateWalk(date)
                case .changedMonth(let date) :
                    self.updateMonthly(date: date)
                }
            }
            .onReceive(self.dataProvider.$result){res in
                guard let res = res else { return }
                if !res.id.hasPrefix(self.tag) {return}
                switch res.type {
                case .getMonthlyWalk(let userId, let date) :
                    if userId == self.userId, let datas = res.data as? [String] {
                        self.updatedMonthly(datas: datas, date:date)
                    }
                case .getWalks(let date):
                    if let datas = res.data as? [WalkData] {
                        self.updatedWalk(datas: datas, date:date)
                    }
                default : break
                }
            }
            .onAppear(){
                self.userId = self.user.snsUser?.snsID ?? ""
                self.updateMonthly(date: AppUtil.networkTimeDate())
            }
        if self.datas.isEmpty {
            EmptyItem(type: .myList)
            if self.walkManager.status == .ready {
                FillButton(
                    type: .fill,
                    text: String.button.startWalking,
                    color: Color.brand.primary
                    
                ){_ in
                    self.pagePresenter.changePage(PageProvider.getPageObject(.walk))
                }
            }
        } else {
            ForEach(self.datas) { data in
                WalkListItem(
                    data: data, imgSize: self.walkListSize)
                {
                    self.move(data: data)
                }
            }
        }
    }
    
    @State var userId:String = ""
    @State var yyyyMM:String = ""
    @State var yyyyMMdd:String = ""
    @State var datas:[WalkListItemData] = []
    @State var isToday:Bool = false
    @State var currentDate:String = ""
    @State var walkListSize:CGSize = .zero
    private func updateMonthly(date:Date){
        let yyyyMM = date.toDateFormatter(dateFormat: "yyyyMM")
        if yyyyMM == self.yyyyMM {return}
        self.yyyyMM = yyyyMM
        self.dataProvider.requestData(q: .init(id:self.tag, type: .getMonthlyWalk(userId: self.userId , date:date)))
        
    }
    
    private func updatedMonthly(datas:[String], date:Date){
        let yyyyMM = date.toDateFormatter(dateFormat: "yyyyMM")
        if self.yyyyMM != yyyyMM {return}
        let selectAbleDate = datas.map{
            $0.toDate(dateFormat: "yyyy-MM-dd")?.toDateFormatter(dateFormat: "yyyyMMdd") ?? ""
        }
        self.calenderModel.selectAbleDate = selectAbleDate
        self.calenderModel.request = .reset(date.toDateFormatter(dateFormat:"yyyyMM"))
        if self.yyyyMMdd.isEmpty {
            self.updateWalk(AppUtil.networkTimeDate())
        }
        
    }
    private func updateWalk(_ date:Date){
        let yyyyMMdd = date.toDateFormatter(dateFormat: "yyyyMMdd")
        if yyyyMMdd == self.yyyyMMdd {return}
        self.yyyyMMdd = yyyyMMdd
        self.isToday = AppUtil.networkTimeDate().toDateFormatter(dateFormat: "yyyyMMdd") == yyyyMMdd
        self.datas = []
        
        let w = self.listSize
        self.walkListSize = CGSize(width: w, height: w * Dimen.item.walkList.height / Dimen.item.walkList.width)
        self.dataProvider.requestData(q: .init(id:self.tag, type: .getWalks(date: date)))
    }
    private func updatedWalk(datas:[WalkData], date:Date?){
        guard let date = date else {return}
        let yyyyMMdd = date.toDateFormatter(dateFormat: "yyyyMMdd") 
        if self.yyyyMMdd != yyyyMMdd {return}
        self.currentDate = date.toDateFormatter(dateFormat: "EEEE, MMMM d") + (self.isToday ? " ("+String.app.today+")" : "")
        self.datas = datas.map{WalkListItemData().setData($0, idx: 0)}.filter{$0.imagePath != nil}.reversed()
        
        guard let obj = self.pageObservable.pageObject, let data = self.datas.first  else { return }
        if obj.getParamValue(key: .isInitAction) as? Bool == true {
            self.move(data: data)
        }
    }
    
    private func move(data:WalkListItemData){
        guard let walkData = data.originData else {return}
        let mission = Mission().setData(walkData).setData(self.dataProvider.user)
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.walkInfo)
                .addParam(key: .data, value: mission)
            
        
        )
    }
}


