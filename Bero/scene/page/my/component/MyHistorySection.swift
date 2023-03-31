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
                    type: .place(icon:  MissionApi.Category.walk.icon),
                    sizeType: .small,
                    funcType: .more,
                    name: MissionApi.Category.walk.text + " " + String.pageTitle.history,
                    description: self.walkDescription,
                    distance: self.walkDistance,
                    action: { _ in
                        self.moveHistory()
                    }
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
        self.walkDistance = user.exerciseDistance
        self.walkDescription = String.pageText.historyCompleted.replace(user.totalWalkCount.description)
    }
    
    private func moveHistory(){
        self.dataProvider.user.currentPet = nil
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.walkHistory)
                .addParam(key: .data, value: self.dataProvider.user)
        )
    }
    
}


