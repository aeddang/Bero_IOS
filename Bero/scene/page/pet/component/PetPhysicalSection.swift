import Foundation
import SwiftUI

struct PetPhysicalSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var profile:PetProfile

    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.physicalInformation, buttons:self.profile.isMypet ? [.edit] : []){ type in
                switch type {
                case .edit :
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.modifyPetHealth)
                            .addParam(key: .data, value: profile)
                    )
                default : break
                }
                
            }
            HStack(spacing:Dimen.margin.thin){
                PropertyInfo(
                    title: String.app.weight,
                    value: self.weight
                )
                PropertyInfo(
                    title: String.app.height,
                    value: self.height
                )
                PropertyInfo(
                    title: String.app.immunization,
                    value: self.immunization
                )
            }
            if self.profile.isMypet {
                HStack(spacing: 0){
                    Text(String.app.animalId)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin, color: Color.app.grey400))
                        .fixedSize()
                    Spacer()
                    Text(self.animalId)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin, color: Color.app.grey500))
                        .fixedSize()
                }
                HStack(spacing: 0){
                    Text(String.app.microchip)
                        .modifier(RegularTextStyle(
                            size: Font.size.thin, color: Color.app.grey400))
                        .fixedSize()
                    Spacer()
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
            self.height = h.description + String.app.cm
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


