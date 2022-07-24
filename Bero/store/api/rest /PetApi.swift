//
//  PetApi.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2021/12/24.
//

import Foundation
import UIKit
class PetApi :Rest{
    func get(user:SnsUser, completion: @escaping (ApiItemResponse<PetData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["userId"] = user.snsID
       
        fetch(route: PetApiRoute (method: .get, query: params), completion: completion, error:error)
    }
    func get(petId:Int, completion: @escaping (ApiContentResponse<PetData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: PetApiRoute (method: .get, commandId: petId.description), completion: completion, error:error)
    }
    
    func post(user:SnsUser, pet:PetProfile, completion: @escaping (ApiContentResponse<PetData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String: String]()
        params["userId"] = user.snsID
        fetch(route: PetApiRoute(method: .post, query: params),
           constructingBlock:{ data in
            if let value = pet.nickName { data.append(value: value, name: "name") }
            if let value = pet.species { data.append(value: value, name: "breed") }
            if let value = pet.birth?.toDateFormatter() { data.append(value: value.subString(start: 0, len: 19), name: "birthdate") }
            if let value = pet.gender?.apiDataKey() { data.append(value: value, name: "sex") }
            if let value = pet.microfin { data.append(value: value, name: "regNumber") }
            data.append(value: "1", name: "level")
            let status = PetProfile.getStatusValue(pet)
            if !status.isEmpty {
                data.append(value:  status.reduce("", {$0 + "," + $1}).subString(1) , name: "status")
            }
            if let value = pet.image?.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "profileImage.jpg",mimeType:"image/jpeg")
            }
        }, completion: completion, error:error)
    }
    
    func put(petId:Int, pet:ModifyPetProfileData, completion: @escaping (Blank) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: PetApiRoute(method: .put, commandId: petId.description),
           constructingBlock:{ data in
            if let value = pet.nickName { data.append(value: value, name: "name") }
            if let value = pet.species { data.append(value: value, name: "breed") }
            if let value = pet.birth?.toDateFormatter() { data.append(value: value.subString(start: 0, len: 19), name: "birthdate") }
            if let value = pet.gender?.apiDataKey() { data.append(value: value, name: "sex") }
            if let value = pet.microfin { data.append(value: value, name: "regNumber") }
            if let value = pet.weight { data.append(value: value.description, name: "weight") }
            if let value = pet.size { data.append(value: value.description, name: "size") }
            let status = PetProfile.getStatusValue(pet)
            if !status.isEmpty {
                data.append(value:  status.reduce("", {$0 + "," + $1}).subString(1) , name: "status")
            }
        }, completion: completion, error:error)
    }
    
    func put(petId:Int, image:UIImage, completion: @escaping (Blank) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: PetApiRoute(method: .put, commandId: petId.description),
           constructingBlock:{ data in
            if let value = image.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "profileImage.jpg",mimeType:"image/jpeg")
            }
        }, completion: completion, error:error)
    }
    
    func delete(petId:Int, completion: @escaping (Blank) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: PetApiRoute(method: .delete, commandId: petId.description), completion: completion, error:error)
    }
    
}

struct PetApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "pets"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

