import Foundation
import SwiftUI

struct TotalWalkSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var user:User
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
            
            Text(WalkManager.viewDistance(self.totalDistance))
                .modifier(SemiBoldTextStyle(
                    size: Font.size.bold,
                    color: Color.app.black
                ))
                .padding(.top, Dimen.margin.regularUltra)
               
            Text(String.pageText.walkHistoryText1)
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
    @State var totalPct:String? = nil
    @State var profile:PetProfile? = nil
    private func updatedWalk(){
        if let profile = self.profile {
            self.totalDistance = profile.totalExerciseDistance ?? 0
            self.totalDuration = profile.totalExerciseDuration ?? 0
        } else {
            self.totalDistance = user.totalWalkDistance
            self.totalDuration = user.exerciseDuration
        }
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


