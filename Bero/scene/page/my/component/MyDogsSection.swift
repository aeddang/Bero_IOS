import Foundation
import SwiftUI

struct MyDogsSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    var body: some View {
        VStack(spacing:Dimen.margin.tiny){
            TitleTab(type:.section, title: String.pageText.myDogs, buttons:[.manageDogs])
            { type in
                switch type {
                case .viewMore : break
                default : break
                }
            }
            ForEach(self.pets) { pet in
                PetProfileInfo( profile: pet){
                    
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
        if self.pets.isEmpty {
            self.pets = [PetProfile().empty()]
        }
    }
}


