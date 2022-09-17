import Foundation
import SwiftUI
import GoogleMaps
import GooglePlaces
import QuartzCore

extension PageWalk {
    
    func onMapMarkerSelect(_ marker:GMSMarker){
       
        if let mission = marker.userData as? Mission {
            switch mission.type {
            case .user :
                self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkUser).addParam(key: .data, value: mission))
            default :
                self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkMission).addParam(key: .data, value: mission))
            }
        } else if let place = marker.userData as? Place {
            self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkPlace).addParam(key: .data, value: place))
        }
        
    }
   
}


