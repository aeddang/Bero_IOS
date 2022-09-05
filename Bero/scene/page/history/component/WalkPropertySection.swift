import Foundation
import SwiftUI

struct WalkPropertySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var mission:Mission
    var body: some View {
        HStack(spacing:Dimen.margin.thin){
            PropertyInfo(
                icon: Asset.icon.schedule,
                title: "Avg. Time",
                value: self.mission.viewDuration,
                bgColor: Color.transparent.clear
            )
            PropertyInfo(
                icon: Asset.icon.speed,
                title: "Avg. Speed",
                value: self.mission.viewSpeed,
                bgColor: Color.transparent.clear
            )
            PropertyInfo(
                icon: Asset.icon.navigation_outline,
                title: "Avg. Distance",
                value: self.mission.viewDistance,
                bgColor: Color.transparent.clear
            )
        }
    }
}

struct PetWalkPropertySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var profile:PetProfile
    
    @State var duration:String = ""
    @State var speed:String = ""
    @State var distance:String = ""
    var body: some View {
        HStack(spacing:Dimen.margin.thin){
            
            PropertyInfo(
                icon: Asset.icon.schedule,
                title: "Total. Time",
                value: self.duration,
                bgColor: Color.transparent.clear
            )
            PropertyInfo(
                icon: Asset.icon.speed,
                title: "Avg. Speed",
                value: self.speed,
                bgColor: Color.transparent.clear
            )
            PropertyInfo(
                icon: Asset.icon.navigation_outline,
                title: "Total. Distance",
                value: self.distance,
                bgColor: Color.transparent.clear
            )
        }
        .onAppear{
            let d = self.profile.totalExerciseDistance ?? 0
            let dr = self.profile.totalExerciseDuration ?? 0
            self.distance = WalkManager.viewDistance(d)
            self.duration = WalkManager.viewDuration(dr)
            let spd = d == 0 || dr == 0 ? 0 : d/dr
            self.speed = WalkManager.viewSpeed(spd)
        }
    }
}





