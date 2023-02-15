import Foundation
import SwiftUI

struct MyDogsSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.myDogs, buttons:[.manageDogs])
            { type in
                switch type {
                case .manageDogs :
                    self.pagePresenter.openPopup(PageProvider.getPageObject(.manageDogs))
                default : break
                }
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            if self.pets.isEmpty {
                EmptyItem(type: .myList)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Dimen.margin.tiny){
                        if self.hasRepresentative , let profile = self.me {
                            UserProfileInfo(profile:profile, sizeType: .big){
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.modifyUser)
                                )
                            }
                            .frame(width: Dimen.item.petList)
                        }
                        ForEach(self.pets.filter{!$0.isRepresentative}) { pet in
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
            case .addedDog, .deletedDog,. updatedProfile: self.update()
            default : break
            }
        }
        .onAppear(){
            self.update()
        }
    }
    @State var hasRepresentative = false
    @State var me:UserProfile? = nil
    @State var pets:[PetProfile] = []
    
    private func update(){
        self.hasRepresentative = self.dataProvider.user.representativePet != nil
        self.me = self.dataProvider.user.currentProfile
        self.pets = self.dataProvider.user.pets
    }
    
    private func movePetPage(_ profile:PetProfile){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.dog)
                .addParam(key: .data, value: profile)
                .addParam(key: .subData, value: self.dataProvider.user)
        )
    }
}


