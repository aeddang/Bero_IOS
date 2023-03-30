//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import GoogleMaps

struct LocationInfo: PageComponent{
    @EnvironmentObject var walkManager:WalkManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var viewModel:PlayMapModel = PlayMapModel()
    var time:String? = nil
    var body: some View {
        HStack(spacing:Dimen.margin.tinyExtra){
            VStack(alignment: .leading, spacing: 0){
                Spacer().modifier(MatchHorizontal(height: 0))
                HStack(spacing:Dimen.margin.tinyExtra){
                    if let text = self.time {
                        Text(text)
                            .modifier(RegularTextStyle(
                                size: Font.size.light,
                                color: Color.app.grey400
                            ))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .frame(width: 47, alignment: .leading)
                    } else {
                        Text(self.location ?? String.pageText.walkLocationNotFound)
                            .modifier(RegularTextStyle(
                                size: Font.size.light,
                                color: Color.app.grey400
                            ))
                    }
                    Text("|")
                        .modifier(MediumTextStyle(
                            size: Font.size.light,
                            color: Color.brand.primary
                        ))
                    
                    if let icon = self.weatherIcon {
                        ImageView(
                            url:icon,
                            contentMode: .fit)
                        .frame(width: Dimen.icon.light, height: Dimen.icon.light)
                    }
                    
                    if let temperature = self.temperature {
                        Text(temperature)
                            .modifier(RegularTextStyle(
                                size: Font.size.light,
                                color: Color.app.grey400
                            ))
                    }
                    if SystemEnvironment.isTestMode {
                        Text(self.zipCode ?? "")
                            .modifier(RegularTextStyle(
                                size: Font.size.light,
                                color: Color.app.grey400
                            ))
                            .onTapGesture{
                            
                                UIPasteboard.general.string = self.zipCode ?? "위치정보없음"
                                self.appSceneObserver.event = .toast("복사되었습니다")
                            }
                    }
                    /*
                     if let weather = self.weather {
                     Text(weather)
                     .modifier(RegularTextStyle(
                     size: Font.size.light,
                     color: Color.app.grey400
                     ))
                     }
                     */
                }
            }
            
        }
        .onReceive(self.walkManager.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updateViewLocation(let loc) : self.updatedLocation(location: loc)
            default: break
            }
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .getWeatherCity, .getWeather :
                guard let data = res.data as? WeatherCityData else { return }
                //self.weather = data.desc
                if let temp = data.temp {
                    self.temperature = temp.toTruncateDecimal(n: 1) + "°C"
                }
                if let icon = data.iconId {
                    self.weatherIcon = "http://openweathermap.org/img/wn/" + icon + "@2x.png"
                }
                
            default : break
            }
        }
        .onAppear(){
            self.updatedLocation()
        }
    }
    @State var pets:[PetProfile] = []
    @State var location:String? = nil
    @State var temperature:String? = nil
    @State var weatherIcon:String? = nil
    @State var zipCode:String? = nil
    private func updatedLocation(location:CLLocation? = nil){
        guard let loc = location ?? self.walkManager.currentLocation else {return}
        self.requestWeather(loc:loc)
        self.walkManager.locationObserver.convertLocationToAddress(location: loc){ address in
            self.zipCode = address.zipCode
            guard let state = address.state else {return}
            if let city = address.city {
                if let street = address.street {
                    self.location = street
                } else {
                    self.location = city
                }
            } else {
                self.location = state
            }
        }
    }

    private func requestWeather(loc:CLLocation) {
        
        self.dataProvider.requestData(q: .init(type: .getWeather(loc), isOptional: true))
    }
    
}



#if DEBUG
struct LocationInfo_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            LocationInfo(
            
            )
        }
        .padding(.all, 10)
        .background(Color.app.white)
    }
}
#endif
