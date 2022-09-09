import Foundation
import SwiftUI

struct UserHistorySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var user:User
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.history){ type in }
            
            ValueBox(
                datas: self.datas
            )
        }
        .onAppear(){
            self.updated()
        }
    }
    
    @State var datas:[ValueData] = []
    private func updated(){
        let walk = ValueData(idx: 0, type: .value(.walkComplete, value: Double(self.user.totalWalkCount)))
        let mission = ValueData(idx: 1, type: .value(.missionComplete, value: Double(self.user.totalMissionCount)))
        self.datas = [walk, mission]
    }
}


