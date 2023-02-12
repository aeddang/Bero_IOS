//
//  LockScreenComponent.swift
//  Bero
//
//  Created by JeongCheol Kim on 2023/02/12.
//

import Foundation
import SwiftUI
import WidgetKit


struct LockScreen:View{
    var title:String = ""
    var time:String = ""
    var distance:String = ""
    var body: some View {
        ZStack(alignment: .topTrailing){
            Image(Asset.appIconCircle)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimen.icon.light, height: Dimen.icon.light)
                .padding(.all, Dimen.margin.thin)
            VStack (spacing: Dimen.margin.regular){
                HStack(spacing: 0){
                    VStack(alignment: .leading, spacing: 0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        Text(title)
                            .font(.custom(Font.familySystem.semiBold, size: Font.size.bold))
                            .fontWeight(.semibold)
                            .lineSpacing(Font.spacing.thin)
                            .foregroundColor(Color.app.white)
                            .lineLimit(1)
                    }
                    
                    
                }
                HStack(spacing: 0){
                    ScreenPropertyInfo(
                        icon: Asset.icon.schedule,
                        title: String.app.time,
                        value: self.time,
                        unit: nil
                    )
                    ScreenPropertyInfo(
                        icon: Asset.icon.navigation_outline,
                        title: String.app.distance,
                        value: self.distance,
                        unit: String.app.km
                    )
                }
            }
            .padding(.all, Dimen.margin.regularUltra)
        }
    }
}

struct ScreenPropertyInfo:View{
    var icon:String? = nil
    var title:String? = nil
    var value:String = ""
    var unit:String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing:0){
            Spacer().modifier(MatchHorizontal(height: 0))
            HStack(spacing: 0){
                if let icon = self.icon {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.brand.primary)
                        .frame(width:Dimen.icon.light,height: Dimen.icon.light)
                }
                if let title = self.title {
                    Text(title)
                        .font(.custom(Font.familySystem.regular, size: Font.size.tiny))
                        
                        .foregroundColor(Color.app.white)
                }
            }
            HStack(alignment: .bottom, spacing: Dimen.margin.micro){
                Text(value)
                    .font(.custom(Font.familySystem.bold, size: 40))
                    .foregroundColor(Color.app.white)
                    .fontWeight(.bold)
                    .frame(height: 40)
                if let unit = self.unit {
                    Text(unit)
                        .font(.custom(Font.familySystem.light, size: Font.size.tiny))
                        .foregroundColor(Color.app.white)
                        .padding(.bottom, Dimen.margin.micro)
                }
            }
        }
        
    }
}
#if DEBUG
struct LockScreenComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        HStack(){
            LockScreen(
                title: "BERO",
                time: "00:00",
                distance: "100.2"
            )
        }
        .background(Color.app.black)
    }
}
#endif
