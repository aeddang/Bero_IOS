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
        var walkDistence:Double = 0
    }
    // Fixed non-changing properties about your activity go here!
    var name: String
}
@available(iOS 16.1, *)
struct BeroLockScreenLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BeroLockScreenAttributes.self) { context in
           
            // Lock screen/banner UI goes here
            HStack {
                Image(Asset.icon.walk)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.brand.primary)
                VStack {
                    Text(context.attributes.name)
                    Text(context.state.walkDistence.description)
                    Text(context.state.walkTime.description)
                }
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.center) {
                    VStack{
                        HStack {
                            Image(Asset.icon.walk)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.brand.primary)
                            Text(context.attributes.name)
                        }
                        Text(self.viewDistance(context.state.walkDistence))
                        Text(self.viewDuration(context.state.walkTime))
                    }
                }
                
            } compactLeading: {
                HStack {
                    Image(Asset.icon.walk)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.brand.primary)
                    Text(self.viewDistance(context.state.walkDistence))
                }
            } compactTrailing: {
                Text(self.viewDuration(context.state.walkTime))
            } minimal: {
                HStack {
                    Image(Asset.icon.walk)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.brand.primary)
                    Text(self.viewDistance(context.state.walkDistence))
                }
            } 
            //.widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
    
    private func viewDistance(_ value:Double) -> String {
        return (value / 1000).toTruncateDecimal(n:1) + String.app.km
    }
    private func viewDuration(_ value:Double) -> String {
        return value.secToMinString()
    }
}


