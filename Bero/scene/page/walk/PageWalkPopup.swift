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
                self.pagePresenter.closePopup(pageId: .popupWalkPlace)
                self.pagePresenter.closePopup(pageId: .popupWalkMission)
     
                if self.pagePresenter.hasPopup(find: .popupWalkUser) {
                    self.pagePresenter.onPageEvent(
                        self.pageObject,
                        event: .init(id: PageID.popupWalkUser ,type: .pageChange, data: mission)
                    )
                   
                    return
                }
                
                self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkUser).addParam(key: .data, value: mission))
            default :
                self.pagePresenter.closePopup(pageId: .popupWalkPlace)
                self.pagePresenter.closePopup(pageId: .popupWalkUser)
                if self.pagePresenter.hasPopup(find: .popupWalkMission) {
                    self.pagePresenter.onPageEvent(
                        self.pageObject,
                        event: .init(id: PageID.popupWalkMission ,type: .pageChange, data: mission)
                    )
                    return
                }
                self.pagePresenter.openPopup(PageProvider.getPageObject(.popupWalkMission).addParam(key: .data, value: mission))
            }
        } else if let place = marker.userData as? Place {
            self.pagePresenter.closePopup(pageId: .popupWalkMission)
            self.pagePresenter.closePopup(pageId: .popupWalkUser)
            if self.pagePresenter.hasPopup(find: .popupWalkPlace) {
                self.pagePresenter.onPageEvent(
                    self.pageObject,
                    event: .init(id: PageID.popupWalkPlace ,type: .pageChange, data: place)
                )
                return
            }
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


