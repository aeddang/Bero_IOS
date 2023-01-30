import Foundation
import SwiftUI

struct MissionPlayInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var mission:Mission
    var body: some View {
        ValueBox(
            datas: self.datas
        )
        .onAppear(){
            self.updated()
        }
    }
    
    @State var datas:[ValueData] = []
    private func updated(){
        let walkData = ValueData(idx: 0, type: .value(.expEarned, value: Double(mission.exp)))
        let pointData = ValueData(idx: 1, type: .value(.pointEarned, value: Double(mission.point)))
        self.datas = [walkData, pointData]
    }
}


