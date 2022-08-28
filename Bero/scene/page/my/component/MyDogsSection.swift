import Foundation
import SwiftUI

struct MyDogsSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.myDogs, buttons:self.pets.isEmpty ? [] : [.manageDogs])
            { type in
                switch type {
                case .manageDogs : break
                default : break
                }
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            if self.pets.isEmpty {
                EmptyItem(type: .myList)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
            } else if self.pets.count == 1, let pet = self.pets.first{
                PetProfileInfo( profile: pet){
                    self.movePetPage(pet)
                }
                .padding(.horizontal, Dimen.app.pageHorinzontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Dimen.margin.tiny){
                        ForEach(self.pets) { pet in
                            PetProfileInfo( profile: pet){
                                self.movePetPage(pet)
                            }
                            .frame(width: Dimen.item.petList)
                        }
                    }
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
                }
            }
        }
        .onReceive(self.dataProvider.user.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .addedDog, .deletedDog: self.update()
            default : break
            }
        }
        .onAppear(){
            self.update()
        }
    }
    @State var pets:[PetProfile] = []
    
    private func update(){
        self.pets = self.dataProvider.user.pets
    }
    
    private func movePetPage(_ profile:PetProfile){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.myDog)
                .addParam(key: .data, value: profile)
        )
    }
}


