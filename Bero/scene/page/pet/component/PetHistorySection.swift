import Foundation
import SwiftUI

struct PetHistorySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var user:User
    @ObservedObject var profile:PetProfile
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.history){ type in }
            if self.profile.isMypet {
                Button(action: {
                    self.user.currentPet = profile
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.walkHistory)
                            .addParam(key: .data, value: self.user)
                    )
                }) {
                    HorizontalProfile(
                        id: "",
                        type: .place(icon: MissionType.walk.icon),
                        sizeType: .small,
                        funcType: .more,
                        name: MissionType.walk.text + " " + String.pageTitle.history,
                        description: self.walkDescription
                    )
                }
                
            } else {
                ValueBox(
                    datas: self.datas
                )
            }
        }
        .onReceive(self.profile.$totalWalkCount){ value in
            self.walkDescription = String.pageText.historyCompleted.replace(value.description)
        }
        .onAppear(){
            if !self.profile.isMypet {
                self.updated()
            }
        }
    }
    
    @State var walkDescription:String = ""
    @State var datas:[ValueData] = []
    private func updated(){
        let walk = ValueData(idx: 0, type: .value(.walkComplete, value: Double(self.profile.totalWalkCount)))
        self.datas = [walk]
    }
}


