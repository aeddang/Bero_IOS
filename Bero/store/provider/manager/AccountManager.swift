//
//  UserManager.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/12/31.
//

import Foundation
class AccountManager : PageProtocol{
    private let user:User
  
    init(user:User) {
        self.user =  user
    }
    
    func respondApi(_ res:ApiResultResponds){
        switch res.type {
        case .getUser(let user, _) :
            if user.snsID == self.user.snsUser?.snsID, let data = res.data as? UserData {
                self.user.setData(data: data)
            }
        case .getPets(let user, _) :
            if user.snsID == self.user.snsUser?.snsID, let data = res.data as? [PetData] {
                self.user.setData(data: data, isMyPet: true)
            }
        case .updateUser(let user, let data):
            if user.snsID == self.user.snsUser?.snsID {
                self.user.currentProfile.update(data: data)
            }
        case .updateUserImage(let user, let data):
            if user.snsID == self.user.snsUser?.snsID {
                self.user.currentProfile.update(image: data)
            }
        case .registPet(let user, _):
            if user.snsID == self.user.snsUser?.snsID , let data = res.data as? PetData{
                let idx = self.user.pets.count
                self.user.registPetComplete(profile: PetProfile(data: data, isMyPet: true, index: idx))
            }
        case .updatePet(let petId, let data):
            if let pet = self.user.pets.first(where: {$0.petId == petId}) {
                pet.update(data: data)
            }
            
        case .updatePetImage(let petId, let data):
            if let pet = self.user.pets.first(where: {$0.petId == petId}) {
                pet.update(image: data)
            }
        case .deletePet(let petId):
            self.user.deletePet(petId: petId)
                
        default : break
        }
    }
    
    func errorApi(_ err:ApiResultError, appSceneObserver:AppSceneObserver?){
        switch err.type {
        case .getUser :
            appSceneObserver?.alert = .alert(nil, String.alert.getUserProfileError )
        default : break
        }
    }
}
