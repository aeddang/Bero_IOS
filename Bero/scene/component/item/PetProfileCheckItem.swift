import Foundation
import SwiftUI

struct PetProfileCheckItem: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var profile:PetProfile
    var body: some View {
        HorizontalProfile(
            type: .pet,
            funcType: .check(self.check),
            image: self.profile.image,
            imagePath: self.profile.imagePath,
            name: self.profile.name,
            gender: self.profile.gender,
            isNeutralized: self.profile.isNeutralized,
            age: self.profile.birth?.toAge(),
            breed: self.profile.breed
        ){ _ in
            withAnimation{
                self.check.toggle()
            }
            self.profile.isWith = self.check
        }
        .onAppear(){
            self.check = self.profile.isWith
        }
    }
    @State var check:Bool = false
   
}
