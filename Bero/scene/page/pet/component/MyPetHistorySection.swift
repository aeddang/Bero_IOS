import Foundation
import SwiftUI

struct MyPetHistorySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:PetProfile
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
                    description: self.walkDescription
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
                    description: self.missionDescription
                )
            }
        }
        .onReceive(self.profile.$totalWalkCount){ value in
            self.walkDescription = String.pageText.historyCompleted.replace(value.description)
        }
        .onReceive(self.profile.$totalMissionCount){ value in
            self.missionDescription = String.pageText.historyCompleted.replace(value.description)
        }
        
    }
    @State var walkDescription:String = ""
    @State var missionDescription:String = ""
   
}


