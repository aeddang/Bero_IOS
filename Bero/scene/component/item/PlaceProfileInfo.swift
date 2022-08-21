import Foundation
import SwiftUI

struct PlaceProfileInfo: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:Place
    var action: (() -> Void)
    var body: some View {
        Button(action: {
            self.action()
        }) {
            HorizontalProfile(
                id: "",
                type: .place(),
                sizeType: .small,
                name: profile.name,
                adress: nil
            )
        }
    }
}


