import Foundation
import SwiftUI

struct WalkPropertySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var mission:Mission
    var action: ((Int) -> Void)? = nil
    var body: some View {
        VStack(spacing:0){
            if mission.walkPath?.paths.isEmpty == false, let path = mission.walkPath?.paths {
                ZStack{
                    Image(Asset.image.route_bg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .modifier(MatchHorizontal(height: 200))
                        .clipped()
                    GraphPolygon(
                        selectIdx: path.filter{$0.smallPictureUrl != nil}.map{$0.idx},
                        points: path.map{CGPoint(x: $0.tx, y:$0.ty )},
                        action: self.action)
                    .frame(width: 160, height: 160)
                }
            }
            
            HStack(spacing:Dimen.margin.tiny){
                PropertyInfo(
                    type:.blank,
                    icon: Asset.icon.schedule,
                    title: String.app.time,
                    value: self.mission.viewDuration
                )
                PropertyInfo(
                    type:.blank,
                    icon: Asset.icon.speed,
                    title: String.app.speed,
                    value: self.mission.viewSpeed
                )
                PropertyInfo(
                    type:.blank,
                    icon: Asset.icon.navigation_outline,
                    title: String.app.distance,
                    value: self.mission.viewDistance
                )
            }
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
                type:.blank,
                icon: Asset.icon.schedule,
                title: "Total. " + String.app.time,
                value: self.duration
            )
            PropertyInfo(
                type:.blank,
                icon: Asset.icon.speed,
                title: "Avg. " + String.app.speed,
                value: self.speed
            )
            PropertyInfo(
                type:.blank,
                icon: Asset.icon.navigation_outline,
                title: "Total. " + String.app.distance,
                value: self.distance
            )
        }
        .onAppear{
            let d = self.profile.totalExerciseDistance ?? 0
            let dr = self.profile.totalExerciseDuration ?? 0
            self.distance = WalkManager.viewDistance(d)
            self.duration = WalkManager.viewDuration(dr)
            let dh = dr/3600
            let spd = d == 0 || dh == 0 ? 0 : d/dh
            self.speed = WalkManager.viewSpeed(spd)
        }
    }
}


struct ReportWalkPropertySection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    var data:WalkReport
    @State var duration:String = ""
    @State var speed:String = ""
    @State var distance:String = ""
    var body: some View {
        HStack(spacing:Dimen.margin.thin){
            PropertyInfo(
                type:.blank,
                icon: Asset.icon.schedule,
                title: "Total. " + String.app.time,
                value: self.duration
            )
            PropertyInfo(
                type:.blank,
                icon: Asset.icon.speed,
                title: "Avg. " + String.app.speed,
                value: self.speed
            )
            PropertyInfo(
                type:.blank,
                icon: Asset.icon.navigation_outline,
                title: "Total. " + String.app.distance,
                value: self.distance
            )
        }
        .onAppear{
            let d = self.data.distance ?? 0
            let dr = self.data.duration ?? 0
            self.distance = WalkManager.viewDistance(d)
            self.duration = WalkManager.viewDuration(dr)
            let dh = dr/3600
            let spd = d == 0 || dh == 0 ? 0 : d/dh
            self.speed = WalkManager.viewSpeed(spd)
        }
    }
}




