import Foundation
import SwiftUI

struct UserHistorySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var user:User
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.history, buttons:user.isFriend ? [.viewMore] : []){ type in
                guard let id = user.snsUser?.snsID else {return}
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.walkList)
                        .addParam(key: .id, value: id)
                
                )
            }
            
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
        let mission = ValueData(idx: 1, type: .value(.walkDistance, value: Double(self.user.totalWalkDistance)))
        self.datas = [walk, mission]
    }
}


