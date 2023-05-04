import Foundation
import SwiftUI

struct UsersDogSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    let user:User
    var isSimple:Bool = false
    var body: some View {
        VStack(spacing:Dimen.margin.regularExtra){
            if !self.isSimple {
                TitleTab(type:.section, title: String.pageTitle.usersDogs.replace(user.representativeName))
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
            }
            if self.pets.isEmpty {
                EmptyItem(type: .myList)
                    .padding(.horizontal, Dimen.app.pageHorinzontal)
            } else {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Dimen.margin.tiny){
                        if self.user.representativePet != nil {
                            UserProfileInfo(profile:self.user.currentProfile, sizeType: .big){
                                if self.user.currentProfile.imagePath?.isEmpty == false {
                                    self.pagePresenter.openPopup(
                                        PageProvider.getPageObject(.pictureViewer)
                                            .addParam(key: .data, value: self.user.currentProfile.imagePath)
                                    )
                                }
                            }
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
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getPets(let userId, _):
                if userId == self.user.snsUser?.snsID, let data = res.data as? [PetData] {
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
        self.dataProvider.requestData(q: .init(id:self.tag, type: .getPets(userId:snsUser.snsID, isCanelAble: true)))
    }
    private func movePetPage(_ profile:PetProfile){
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.dog)
                .addParam(key: .data, value: profile)
                .addParam(key: .subData, value: self.user)
        )
    }
}


