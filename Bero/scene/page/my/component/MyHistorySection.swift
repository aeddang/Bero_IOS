import Foundation
import SwiftUI

struct MyHistorySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(
                type:.section, title: String.pageTitle.history,
                action: { type in }
            )
            Button(action: {
                self.moveHistory()
            }) {
                HorizontalProfile(
                    id: "",
                    type: .place(icon: MissionType.walk.icon),
                    sizeType: .small,
                    funcType: .more,
                    name: MissionType.walk.text + " " + String.pageTitle.history,
                    description: self.walkDescription,
                    distance: self.walkDistance,
                    action: { _ in
                        self.moveHistory()
                    }
                )
            }
            /*
            Button(action: {
                self.moveMissionHistory()
            }) {
                HorizontalProfile(
                    id: "",
                    type: .place(icon: MissionType.history.icon),
                    sizeType: .small,
                    funcType: .more,
                    name: MissionType.history.text + " " + String.pageTitle.history,
                    description: self.missionDescription,
                    distance: self.missionDistance,
                    action: { _ in
                        self.moveMissionHistory()
                    }
                )
            }
            */
        }
        .onReceive(self.dataProvider.user.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedPlayData: self.update()
            default : break
            }
        }
        .onAppear(){
            self.update()
        }
    }
    @State var walkDistance:Double = 0
    @State var walkDescription:String = ""
    @State var missionDistance:Double = 0
    @State var missionDescription:String = ""
    
    private func update(){
        let user = self.dataProvider.user
        self.walkDistance = user.totalWalkDistance
        self.missionDistance = user.totalMissionDistance
        self.walkDescription = String.pageText.historyCompleted.replace(user.totalWalkCount.description)
        self.missionDescription = String.pageText.historyCompleted.replace(user.totalMissionCount.description)
    }
    
    private func moveHistory(){
        self.dataProvider.user.currentPet = nil
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.walkHistory)
                .addParam(key: .data, value: self.dataProvider.user)
        )
    }
    
    private func moveMissionHistory(){
        self.dataProvider.user.currentPet = nil
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.missionHistory)
                .addParam(key: .data, value: self.dataProvider.user)
        )
    }
}


