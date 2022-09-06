import Foundation
import SwiftUI

struct TotalMissionSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var user:User
    var action:(PetProfile?)->Void
    var body: some View {
        VStack(alignment: .center, spacing:0){
            Spacer().modifier(MatchHorizontal(height: 0))
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
            
            Text(self.totalMission.description + String.app.missions)
                .modifier(SemiBoldTextStyle(
                    size: Font.size.bold,
                    color: Color.app.black
                ))
                .padding(.top, Dimen.margin.regularUltra)
               
            Text(String.pageText.missionHistoryText1)
                .modifier(RegularTextStyle(
                    size: Font.size.thin,
                    color: Color.app.grey500
                ))
            if let pct = totalPct {
                Text(pct)
                    .modifier(RegularTextStyle(
                        size: Font.size.tiny,
                        color: Color.brand.primary
                    ))
            }
        
        }
        .onReceive(self.user.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .updatedPlayData :
                if self.profile == nil {
                    self.updatedMission()
                }
            default : break
            }
        }
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getPets(let user, _):
                if user.snsID == self.user.snsUser?.snsID, let data = res.data as? [PetData] {
                    self.user.setData(data: data, isMyPet: false)
                }
            default : break
            }
        }
        .onAppear(){
            self.profile = self.user.currentPet
            self.updatedMission()
            if user.pets.isEmpty, let snsUser = self.user.snsUser {
                self.dataProvider.requestData(q: .init(id:self.tag, type: .getPets(snsUser, isCanelAble: true)))
                
            }
           
        }
    }
    
    @State var totalMission:Int = 0
    @State var totalPct:String? = nil
    @State var profile:PetProfile? = nil
    private func updatedMission(){
        if let profile = self.profile {
            self.totalMission = profile.totalMissionCount
        } else {
            self.totalMission = user.pets.reduce(0, {$0 + $1.totalMissionCount })
        }
        self.action(self.profile)
    }
    private func onSort(){
        var datas:[String] = self.user.pets.map{$0.name ?? ""}
        datas.insert(String.button.all, at: 0)
        self.appSceneObserver.radio = .sort( (self.tag, datas), title: String.pageText.walkHistorySeletReport){ idx in
            guard let idx = idx else {return}
            let select = datas[idx]
            self.profile = self.user.pets.first(where: {$0.name == select})
            self.user.currentPet = self.profile
            self.updatedMission()
            self.infinityScrollModel.uiEvent = .reload
        }
        
    }
}


