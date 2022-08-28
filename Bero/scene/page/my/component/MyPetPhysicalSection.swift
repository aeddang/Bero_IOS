import Foundation
import SwiftUI

struct MyPetPhysicalSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:PetProfile

    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.physicalInformation){ type in }
            HStack(spacing:Dimen.margin.thin){
                Button(action: {
                    
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.editProfile)
                            .addParam(key: .data, value: self.profile)
                            .addParam(key: .type, value: PageEditProfile.EditType.weight)
                    )
                    
                }) {
                    PropertyInfo(
                        title: String.app.weight,
                        value: self.weight
                    )
                }
                Button(action: {
                    
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.editProfile)
                            .addParam(key: .data, value: self.profile)
                            .addParam(key: .type, value: PageEditProfile.EditType.height)
                    )
                    
                }) {
                    PropertyInfo(
                        title: String.app.height,
                        value: self.height
                    )
                }
                Button(action: {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.editProfile)
                            .addParam(key: .data, value: self.profile)
                            .addParam(key: .type, value: PageEditProfile.EditType.immun)
                    )
                }) {
                    PropertyInfo(
                        title: String.app.immunization,
                        value: self.immunization
                    )
                }
            }
            HStack(spacing: 0){
                Text(String.app.animalId)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin, color: Color.app.grey400))
                    .fixedSize()
                Spacer()
                Button(action: {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.editProfile)
                            .addParam(key: .data, value: self.profile)
                            .addParam(key: .type, value: PageEditProfile.EditType.animalId)
                    )
                }) {
                    Text(self.animalId)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin, color: Color.app.grey500))
                        .fixedSize()
                }
            }
            HStack(spacing: 0){
                Text(String.app.microchip)
                    .modifier(RegularTextStyle(
                        size: Font.size.thin, color: Color.app.grey400))
                    .fixedSize()
                Spacer()
                Button(action: {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.editProfile)
                            .addParam(key: .data, value: self.profile)
                            .addParam(key: .type, value: PageEditProfile.EditType.microchip)
                    )
                }) {
                    Text(self.microchip)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin, color: Color.app.grey500))
                        .fixedSize()
                }
                
            }
        }
        .onReceive(self.profile.$weight){ weight in
            guard let w = weight else {return}
            self.weight = w.description + String.app.kg
        }
        .onReceive(self.profile.$size){ size in
            guard let h = size else {return}
            self.height = h.description + String.app.inch
        }
        .onReceive(self.profile.$immunStatus){ immunStatus in
            guard let status = immunStatus else {return}
            self.immunization = PetProfile.exchangeStringToList(status).count.description
        }
        .onReceive(self.profile.$microchip){ microchip in
            guard let chip = microchip else {return}
            self.microchip = chip
        }
        .onReceive(self.profile.$animalId){ animalId in
            guard let id = animalId else {return}
            self.animalId = id
        }
    }
    @State var weight:String = "-"
    @State var height:String = "-"
    @State var immunization:String = "-"
    @State var animalId:String = String.button.unregistered
    @State var microchip:String = String.button.unregistered
}


