import Foundation
import SwiftUI

struct MyHistorySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.history){ type in }
            Button(action: {
                
            }) {
                HorizontalProfile(
                    id: "",
                    type: .place(icon: MissionType.walk.icon),
                    sizeType: .small,
                    funcType: .more,
                    name: MissionType.walk.text + " " + String.pageTitle.history,
                    description: self.walkDescription,
                    distance: self.walkDistance
                )
            }
            Button(action: {
                
            }) {
                HorizontalProfile(
                    id: "",
                    type: .place(icon: MissionType.history.icon),
                    sizeType: .small,
                    funcType: .more,
                    name: MissionType.history.text + " " + String.pageTitle.history,
                    description: self.missionDescription,
                    distance: self.missionDistance
                )
            }
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
        self.walkDescription = String.pageText.historyCompleted.replace(user.walk.description)
        self.missionDescription = String.pageText.historyCompleted.replace(user.mission.description)
    }
}


