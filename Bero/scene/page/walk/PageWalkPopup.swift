import Foundation
import SwiftUI
import GoogleMaps
import GooglePlaces
import QuartzCore

extension PageWalk {
    func closeAllPopup(){
        self.pagePresenter.closePopup(pageId: .popupWalkPlace)
        self.pagePresenter.closePopup(pageId: .popupWalkMission)
        self.pagePresenter.closePopup(pageId: .popupWalkUser)
    }
    func onMapMarkerSelect(_ marker:GMSMarker){
        self.closeAllPopup()
        if let mission = marker.userData as? Mission {
            if mission.isGroup, let loc = mission.location {
                //self.walkManager.uiEvent = .moveMap(loc)
                return
            }
            switch mission.type {
            case .user :
                self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkUser).addParam(key: .data, value: mission))
            default :
                self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkMission).addParam(key: .data, value: mission))
            }
        } else if let place = marker.userData as? Place {
            if place.isGroup, let loc = place.location {
                //self.walkManager.uiEvent = .moveMap(loc)
                return
            }
            /*
            if self.pagePresenter.hasPopup(find: .popupWalkPlace) {
                self.pagePresenter.onPageEvent(
                    self.pageObject,
                    event: .init(id: PageID.popupWalkPlace ,type: .pageChange, data: place)
                )
                return
            }*/
            self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkPlace).addParam(key: .data, value: place))
        }
        
    }
    func onMapMarkerDisSelect(_ marker:GMSMarker){
    
        if let mission = marker.userData as? Mission {
            switch mission.type {
            case .user :
                self.pagePresenter.closePopup(pageId: .popupWalkUser)
            default :
                self.pagePresenter.closePopup(pageId: .popupWalkMission)
            }
        } else if marker.userData is Place {
            self.pagePresenter.closePopup(pageId: .popupWalkPlace)
        }
        
    }
}


