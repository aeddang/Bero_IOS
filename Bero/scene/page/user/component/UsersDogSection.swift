import Foundation
import SwiftUI

struct UsersDogSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    let user:User
   
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.usersDogs.replace(user.currentProfile.nickName ?? ""))
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
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getPets(let user, _):
                if user.snsID == self.user.snsUser?.snsID, let data = res.data as? [PetData] {
                    self.user.setData(data: data)
                }
            default : break
            }
        }
        .onReceive(self.user.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedDogs : self.pets = self.user.pets
            default : break
            }
        }
        .onAppear{
            self.updatePet()
        }
    }
    @State var pets:[PetProfile] = []
    private func updatePet(){
        if self.user.pets.isEmpty == false {
            self.pets = self.user.pets
            return
        }
        guard let snsUser = self.user.snsUser else { return }
        self.dataProvider.requestData(q: .init(id:self.tag, type: .getPets(snsUser, isCanelAble: true)))
    }
    private func movePetPage(_ profile:PetProfile){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.dog)
                .addParam(key: .data, value: profile)
                .addParam(key: .subData, value: self.user)
        )
    }
}


