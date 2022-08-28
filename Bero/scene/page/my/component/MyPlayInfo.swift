import Foundation
import SwiftUI

struct MyPlayInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var action: ((ValueBox.ValueType) -> Void)? = nil
    var body: some View {
        ValueBox(
            datas: self.datas,
            action: self.action
        )
        .onReceive(self.dataProvider.user.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedPlayData : break
                self.updated()
            default : break
            }
        }
        .onAppear(){
            self.updated()
        }
    }
    
    @State var datas:[ValueData] = []
    private func updated(){
        let user = self.dataProvider.user
        let lvData = ValueData(idx: 0, type: .value(.heart, value: Double(user.lv)))
        let pointData = ValueData(idx: 1, type: .value(.point, value: Double(user.point)))
        self.datas = [lvData, pointData]
    }
}


