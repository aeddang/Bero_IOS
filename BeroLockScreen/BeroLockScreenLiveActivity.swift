//
//  BeroLockScreenLiveActivity.swift
//  BeroLockScreen
//
//  Created by JeongCheol Kim on 2022/12/24.
//

import ActivityKit
import WidgetKit
import SwiftUI


struct BeroLockScreenAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var walkTime:Double = 0
        var walkDistance:Double = 0
        var name: String
    }
    
}
@available(iOS 16.1, *)
struct BeroLockScreenLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BeroLockScreenAttributes.self) { context in
            LockScreen(
                title: context.state.name,
                time: context.state.walkTime.secToMinString(),
                distance: (context.state.walkDistance/1000).toTruncateDecimal(n: 2)
            )
            .activityBackgroundTint(Color.app.black)
            .activitySystemActionForegroundColor(Color.app.black)
            
        }
        dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(Asset.appIconCircle)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack {
                        Text(context.state.walkTime.secToMinString())
                    }
                    .padding(.top, 16.0)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text((context.state.walkDistance/1000).toTruncateDecimal(n: 2) + String.app.km)
                }
            } compactLeading: {
                Image(Asset.appIconCircle)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.light, height: Dimen.icon.light)
            } compactTrailing: {
                Text(context.state.walkTime.secToMinString())
            } minimal: {
                Image(Asset.appIconCircle)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Dimen.icon.light, height: Dimen.icon.light)
            }
        }
    }
}


