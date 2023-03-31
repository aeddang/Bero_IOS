import Foundation
import SwiftUI

struct TotalWalkSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var user:User
    var body: some View {
        VStack(alignment: .leading, spacing:  Dimen.margin.tiny){
            HStack(alignment: .top, spacing:0){
                VStack(alignment: .leading, spacing: 0){
                    Spacer().modifier(MatchHorizontal(height: 0))
                    if let pct = totalPct {
                        Text(pct)
                            .modifier(RegularTextStyle(
                                size: Font.size.tiny,
                                color: Color.brand.primary
                            ))
                    }
                    HStack(alignment: .bottom, spacing: 0){
                        Text(WalkManager.viewDistance(self.totalDistance, unit: nil))
                            .modifier(SemiBoldTextStyle(
                                size: 64,
                                color: Color.app.black
                            ))
                            .frame(height: 64)
                        Text(String.app.km)
                            .modifier(
                                RegularTextStyle(
                                    size: Font.size.tiny, color: Color.app.grey400))
                            .padding(.bottom, Dimen.margin.tiny)
                    }
                }
                SortButton(
                    type: .stroke,
                    sizeType: .big,
                    userProgile: self.profile == nil ? self.user.currentProfile : nil,
                    petProgile: self.profile,
                    text: (self.profile == nil ? String.button.all : self.profile?.name) ?? "",
                    color:Color.app.grey400,
                    isSort: true){
                        self.onSort()
                    }
                    .fixedSize()
            }
            HStack(spacing: Dimen.margin.regularUltra){
                PropertyInfo(
                    type:.impect,
                    value: self.totalWalkCount.description,
                    unit: String.app.walks,
                    bgColor: Color.transparent.clear,
                    alignment: .leading
                )
                PropertyInfo(
                    type:.impect,
                    value: WalkManager.viewDuration(self.totalDuration),
                    unit: String.app.time + "(" + String.app.min + ")",
                    bgColor: Color.transparent.clear,
                    alignment: .leading
                )
                PropertyInfo(
                    type:.impect,
                    value: self.speed,
                    unit: String.app.speed + "(" + String.app.kmPerH + ")",
                    bgColor: Color.transparent.clear,
                    alignment: .leading
                )
            }
            .padding(.leading, Dimen.margin.tiny)
                
        }
        .onReceive(self.user.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .updatedPlayData :
                if self.profile == nil {
                    self.updatedWalk()
                }
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getPets(let userId, _):
                if userId == self.user.snsUser?.snsID, let data = res.data as? [PetData] {
                    self.user.setData(data: data)
                }
            default : break
            }
        }
        .onAppear(){
            self.profile = self.user.currentPet
            self.updatedWalk()
            if user.pets.isEmpty, let snsUser = self.user.snsUser {
                self.dataProvider.requestData(q: .init(id:self.tag, type: .getPets(userId:snsUser.snsID, isCanelAble: true)))
                
            }
        }
    }
    
    @State var totalDistance:Double = 0
    @State var totalDuration:Double = 0
    @State var totalWalkCount:Int = 0
    @State var speed:String = ""
    @State var totalPct:String? = nil
    @State var profile:PetProfile? = nil
    private func updatedWalk(){
        if let profile = self.profile {
            self.totalDistance = profile.exerciseDistance ?? 0
            self.totalDuration = profile.exerciseDuration ?? 0
            self.totalWalkCount = profile.totalWalkCount
        } else {
            self.totalDistance = user.exerciseDistance
            self.totalDuration = user.exerciseDuration
            self.totalWalkCount = user.totalWalkCount
        }
        let d = self.totalDistance
        let dr = self.totalDuration
        let spd = d == 0 || dr == 0 ? 0 : d/dr
        self.speed = WalkManager.viewSpeed(spd, unit: nil)
    }
    private func onSort(){
        var datas:[String] = self.user.pets.map{$0.name ?? ""}
        datas.insert(String.button.all, at: 0)
        self.appSceneObserver.radio = .sort( (self.tag, datas), title: String.pageText.walkHistorySeletReport){ idx in
            guard let idx = idx else {return}
            let select = datas[idx]
            self.profile = self.user.pets.first(where: {$0.name == select})
            self.user.currentPet = self.profile
            self.updatedWalk()
        }
    }
}


