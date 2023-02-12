//
//  ApiManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Combine
import CoreLocation
enum ApiStatus{
    case initate, ready, reflash, error
}
enum ApiEvent{
    case initate, error, join
}

enum RewardEvent{
    case exp(value:Double, lvData:MetaData?), point(value:Int, lvData:MetaData?), reward(exp:Double, point:Int, lvData:MetaData?)
}
struct ApiNetwork :Network{
    static fileprivate(set) var accesstoken:String? = nil
    static func reset(){
        Self.accesstoken = nil
    }
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath()
    func onRequestIntercepter(request: URLRequest)->URLRequest{
        guard let token = ApiNetwork.accesstoken else { return request }
        var authorizationRequest = request
        authorizationRequest.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        DataLog.d("token " + token , tag: self.tag)
        return authorizationRequest
    }
    func onDecodingError(data: Data, e:Error) -> Error{
        guard let error = try? self.decoder.decode(ApiErrorResponse.self, from: data) else { return e }
        return ApiError(response: error)
    }
    
    
}


class ApiManager :PageProtocol, ObservableObject{
    let network:Network = ApiNetwork()
    
    @Published var status:ApiStatus = .initate
    @Published var event:ApiEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published var rewardEvent:RewardEvent? = nil
    @Published var result:ApiResultResponds? = nil {didSet{ if result != nil { result = nil} }}
    @Published var error:ApiResultError? = nil {didSet{ if error != nil { error = nil} }}
    
    private var anyCancellable = Set<AnyCancellable>()
    private var apiQ :[ ApiQ ] = []
    private var transition = [String : ApiQ]()
    
    //page Api
    let user:UserApi
    let pet:PetApi
    let album:AlbumApi
    let mission:MissionApi
    let walk:WalkApi
    let friend:FriendApi
    let reward:RewardApi
    let chat:ChatApi
    let recommendation:RecommendationApi
    //Store Api
    let auth:AuthApi
    let userUpdate:UserApi
    let petUpdate:PetApi
    let place:PlaceApi
    let misc:MiscApi
    let vision:VissionApi
    let walking:WalkApi
    
    private var snsUser:SnsUser? = nil
    
    
    init() {
        self.auth = AuthApi(network: self.network)
        self.user = UserApi(network: self.network)
        self.userUpdate = UserApi(network: self.network)
        self.pet = PetApi(network: self.network)
        self.petUpdate = PetApi(network: self.network)
        self.mission = MissionApi(network: self.network)
        self.walk = WalkApi(network: self.network)
        self.place = PlaceApi(network: self.network)
        self.vision = VissionApi(network: self.network)
        self.album = AlbumApi(network: self.network)
        self.misc = MiscApi(network: self.network)
        self.friend = FriendApi(network: self.network)
        self.reward = RewardApi(network: self.network)
        self.chat = ChatApi(network: self.network)
        self.walking = WalkApi(network: self.network)
        self.recommendation = RecommendationApi(network: self.network)
    }
    
    func clear(){
        if self.status == .initate {return}
        self.user.clear()
        self.pet.clear()
        self.mission.clear()
        self.walk.clear()
        self.album.clear()
        self.friend.clear()
        self.reward.clear()
        self.chat.clear()
        self.recommendation.clear()
        self.apiQ.removeAll()
    }
    
    func clearApi(){
        ApiNetwork.accesstoken = nil
        self.snsUser = nil
        self.status = .initate
    }
    
    func initateApi(token:String, user:SnsUser){
        ApiNetwork.accesstoken = token
        self.snsUser = user
        self.status = .ready
        if self.status != .reflash {
            self.event = .initate
        }
        self.executeQ()
    }
    
    func initateApi(user:SnsUser?){
        self.snsUser = user
        self.executeQ()
    }
    
    func initateApi(res:UserAuth? = nil){
        if let res = res {
            ApiNetwork.accesstoken = res.token
        }
        
        self.status = .ready
        self.event = .initate
        self.executeQ()
    }
    
    private func executeQ(){
        self.apiQ.forEach{ q in self.load(q: q)}
        self.apiQ.removeAll()
    }
    
    func load(q:ApiQ){
        self.load(q.type, resultId: q.id, isOptional: q.isOptional, isProcess: q.isProcess)
    }
    
    @discardableResult
    func load(_ type:ApiType, resultId:String = "", isOptional:Bool = false, isLock:Bool = false, isProcess:Bool = false)->String {
        let apiID = resultId //+ UUID().uuidString
        let error = {err in self.onError(id: apiID, type: type, e: err, isOptional: isOptional, isLock: isLock,  isProcess: isProcess)}
        switch type {
        case .joinAuth(let user, let info):
            self.auth.post(user: user, info: info,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
            return apiID
        case .reflashAuth:
            guard let user = self.snsUser else {return apiID}
            self.auth.reflash(user: user,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
            return apiID
        default: break
        }
        
        if status != .ready{
            self.apiQ.append(ApiQ(id: resultId, type: type, isOptional: isOptional, isLock: isLock, isProcess: isProcess))
            return apiID
        }
        switch type {
        case .registPush(let token) :
            self.userUpdate.post(pushToken: token,
                                 completion: {res in self.complated(id: apiID, type: type, res: res)},
                                 error:error)
            
        case .getUser(let user, let isCanelAble) :
            if isCanelAble == true {
                self.user.get(user: user,
                              completion: {res in self.complated(id: apiID, type: type, res: res)},
                              error:error)
            } else {
                self.userUpdate.get(user: user,
                              completion: {res in self.complated(id: apiID, type: type, res: res)},
                              error:error)
            }
        case .getUserDetail(let userId) :
            self.user.get(userId: userId,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .updateUser(let user, let modifyData) :
            self.userUpdate.put(user: user, modifyData:modifyData,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .updateUserImage(let user, let img) :
            self.userUpdate.put(user: user, image: img,
                                completion: {res in self.complated(id: apiID, type: type, res: res)},
                                error:error)
        case .getBlockedUser(let page, let size) :
            self.user.getBlocks(page:page, size: size,
                             completion: {res in self.complated(id: apiID, type: type, res: res)},
                             error:error)
        case .blockUser(let userId, let isBlock) :
            self.userUpdate.block(userId: userId, isBlock: isBlock,
                                completion: {res in self.complated(id: apiID, type: type, res: res)},
                                error:error)
        case .deleteUser :
            self.userUpdate.delete(
                completion: {res in self.complated(id: apiID, type: type, res: res)},
                error:error)
        case .registPet(let user, let pet, let isRepresentative) :
            self.petUpdate.post(user: user, pet: pet, isRepresentative:isRepresentative,
                                completion: {res in self.complated(id: apiID, type: type, res: res)},
                                error:error)
        case .changeRepresentativePet(let petId) :
            self.petUpdate.putRepresentative(petId: petId,
                                             completion:{res in self.complated(id: apiID, type: type, res: res)},
                                             error:error)
        case .updatePet(let petId, let pet) :
            self.petUpdate.put(petId: petId, pet: pet,
                                completion: {res in self.complated(id: apiID, type: type, res: res)},
                                error:error)
        case .updatePetImage(let petId, let img) :
            self.petUpdate.put(petId: petId, image: img,
                                completion: {res in self.complated(id: apiID, type: type, res: res)},
                                error:error)
        case .getPets(let userId , let isCanelAble) :
            if isCanelAble == true {
                self.pet.get(userId: userId,
                             completion: {res in self.complated(id: apiID, type: type, res: res)},
                             error:error)
            } else {
                self.petUpdate.get(userId: userId,
                             completion: {res in self.complated(id: apiID, type: type, res: res)},
                             error:error)
            }
        case .getPet(let petId) :
            self.pet.get(petId: petId, 
                         completion: {res in self.complated(id: apiID, type: type, res: res)},
                         error:error)
        case .deletePet(let petId) :
            self.petUpdate.delete(petId: petId,
                                  completion: {res in self.complated(id: apiID, type: type, res: res)},
                                  error:error)
        case .getMission(let userId , let petId, let date, let cate, let page, let size) :
            self.mission.get(userId: userId, petId: petId, date:date, cate:cate, page:page, size: size,
                             completion: {res in self.complated(id: apiID, type: type, res: res)},
                             error:error)
        case .searchMission(let cate, let search, let searchValue, let location, let distance, let page, let size) :
            self.mission.get(cate: cate, search: search, searchValue:searchValue, location: location, distance: distance, page: page, size: size,
                             completion: {res in self.complated(id: apiID, type: type, res: res)},
                             error:error)
        case .requestRoute(let departure, let destination, _) :
            self.walk.get(departure: departure, destination: destination,
                             completion: {res in self.complated(id: apiID, type: type, res: res)},
                             error:error)
        case .getWalkSummary(let petId) :
            self.walk.getSummary(petId: petId,
                                    completion: {res in self.complated(id: apiID, type: type, res: res)},
                                    error:error)
        case .getMonthlyWalk(let userId, let date) :
            self.walk.getMonthly(userId: userId, date:date,
                                    completion: {res in self.complated(id: apiID, type: type, res: res)},
                                    error:error)
        case .getWalk(let walkId) :
            self.walk.get(id:walkId,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .getUserWalks(let userId, let page, let size) :
            self.walk.get(userId: userId, page: page, size: size,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .getWalks(let date) :
            self.walk.get(date:date,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .searchLatestWalk(let loc, let radius, let min) :
            self.walk.get(
                loc: loc, radius: radius, min: min, page: nil, size: nil,
                completion: { resA in
                    self.walk.getFriend(
                        page: nil, size: nil,
                        completion: {resB in
                            var res = resA
                            var resItems = resA.items.filter{$0.isFriend == false}
                            resItems.append(contentsOf: resB.items)
                            res.items = resItems
                            self.complated(id: apiID, type: type, res: res)
                        },
                        error: {_ in self.complated(id: apiID, type: type, res: resA)})
                    },
                error:error)
        case .searchWalk(let loc, let radius, let min, let page, let size) :
            self.walk.get(loc: loc, radius: radius, min: min, page: page, size: size,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .searchWalkFriends(let page, let size) :
            self.walk.getFriend(page: page, size: size,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .requestNewMission(let location, let distance) :
            self.mission.get(location: location, distance: distance,
                             completion: {res in self.complated(id: apiID, type: type, res: res)},
                             error:error)
       
        case .completeMission(let mission, let pets, let pictureUrl) :
            self.mission.post(mission: mission, pets: pets, pictureUrl: pictureUrl,
                              completion: {res in self.complated(id: apiID, type: type, res: res)},
                              error:error)
            
        case .registWalk(let loc, let pets) :
            self.walking.post(loc: loc, pets: pets,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
        case .updateWalk(let walkId, let loc, let additionalData):
            self.walking.put(id: walkId, loc: loc, status: .Walking, additionalData: additionalData,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
        case .completeWalk(let walkId, let loc, let additionalData):
            self.walking.put(id: walkId, loc: loc, status: .Finish, additionalData: additionalData,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
    
        case .checkHumanWithDog(let img, let thumb) :
            self.vision.post(img: img, thumbImg: thumb, action: .detecthumanwithdog,
                             completion: {res in self.complated(id: apiID, type: type, res: res)},
                             error:error)
        case .getAlbumPictures(let userId, let referenceId, let cate, let searchType, let isExpose, let page , let size) :
            self.album.get(id: userId, referenceId:referenceId, type: cate, searchType:searchType, isExpose: isExpose, page: page, size: size,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error) 
        case .registAlbumPicture(let img, let thumb, let userId, let cate, let isExpose, let referenceId) :
            self.album.post(img: img, thumbImg:thumb, id: userId, type: cate, isExpose: isExpose, referenceId: referenceId,
                            completion: {res in self.complated(id: apiID, type: type, res: res)},
                            error:error)
        case .deleteAlbumPictures(let ids) :
            self.album.delete(ids: ids,
                              completion: {res in self.complated(id: apiID, type: type, res: res)},
                              error:error)
        case .updateAlbumPicture(let pictureId, let isLike, let isExpose) :
            self.album.put(id: pictureId, isLike: isLike, isExpose: isExpose,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
        case .getWeather(let loc) :
            self.misc.getWeather(location: loc,
                                 completion: {res in self.complated(id: apiID, type: type, res: res)},
                                 error:error)
        case .getWeatherCity(let id, let action) :
            self.misc.getWeather(id: id, action: action,
                                 completion: {res in self.complated(id: apiID, type: type, res: res)},
                                 error:error)
        case .getCode(let category, let searchKeyword) :
            self.misc.getCode(category: category, searchKeyword: searchKeyword,
                              completion: {res in self.complated(id: apiID, type: type, res: res)},
                              error:error)
        case .getBanner(let id):
            self.misc.getBanner(id: id,
                              completion: {res in self.complated(id: apiID, type: type, res: res)},
                              error:error)
            
        case .sendReport(let reportType, let postId, let userId) :
            self.misc.postReport(type: reportType, postId:postId, userId:userId,
                                 completion: {res in self.complated(id: apiID, type: type, res: res)},
                                 error:error)
        
        case .getPlace(let location, let distance, let searchType) :
            self.place.get(location: location, distance: distance, searchType: searchType,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
        case .getPlaceVisitors(let placeId, let page , let size) :
            self.place.get(placeId: placeId, page: page, size: size, 
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
        case .registVisit(let place) :
            self.place.post(place: place,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
        case .getFriend(let userId, let page , let size) :
            self.friend.get(userId:userId, action: nil, page: page, size: size,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
        case .getRequestFriend(let page , let size) :
            self.friend.get(action: .requesting, page: page, size: size,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
        case .getRequestedFriend(let page , let size) :
            self.friend.get(action: .isRequested, page: page, size: size,
                           completion: {res in self.complated(id: apiID, type: type, res: res)},
                           error:error)
        case .requestFriend(let userId) :
            self.friend.post(userId: userId,
                            completion: {res in self.complated(id: apiID, type: type, res: res)},
                            error:error)
        case .acceptFriend(let userId) :
            self.friend.put(action: .accept, userId: userId,
                            completion: {res in self.complated(id: apiID, type: type, res: res)},
                            error:error)
        case .rejectFriend(let userId) :
            self.friend.put(action: .reject , userId: userId,
                            completion: {res in self.complated(id: apiID, type: type, res: res)},
                            error:error)
        case .deleteFriend(let userId) :
            self.friend.delete(userId: userId,
                            completion: {res in self.complated(id: apiID, type: type, res: res)},
                            error:error)
        case .getRewardHistory(let userId, let value, let page, let size) :
            self.reward.getHistory(userId: userId, type : value, page: page, size: size,
                                      completion: {res in self.complated(id: apiID, type: type, res: res)},
                                      error:error)
            
        case .getChats(let userId, let page, let size) :
            self.chat.get(userId:userId, page: page, size: size,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .sendChat(let userId, let contents) :
            self.chat.post(userId: userId, contents: contents,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .deleteChat(let chatId) :
            self.chat.delete(chatId: chatId,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .deleteAllChat(let chatIds) :
            self.chat.deleteAll(chatIds: chatIds,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .getChatRooms(let page, let size) :
            self.chat.getRoom(page: page, size: size,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .deleteChatRoom(let roomId) :
            self.chat.deleteRoom(roomId: roomId,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .readChatRoom(let roomId) :
            self.chat.putRoom(roomId: roomId,
                          completion: {res in self.complated(id: apiID, type: type, res: res)},
                          error:error)
        case .getRecommandationFriends :
            self.recommendation.get(action: .friends,
                                    completion: {res in self.complated(id: apiID, type: type, res: res)},
                                    error:error)
        
        default: break
        }
        return apiID
    }
    
    private func complated(id:String, type:ApiType, res:Blank){
        let result:ApiResultResponds = .init(id: id, type:type, data: res)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res)
        }
    }
    private func complated(id:String, type:ApiType, res:[String:Any]){
        guard let status = res["status"] as? String else { return }
        if status != "200" {
            do{
                let data = try JSONSerialization.data(withJSONObject: res, options: .init())
                guard let error = try? JSONDecoder().decode(ApiErrorResponse.self, from: data) else {
                    self.onError( id: id, type: type, e: ApiError(response: ApiErrorResponse.getUnknownError()))
                    return
                }
                return self.onError( id: id, type: type, e: ApiError(response: error))
            } catch {
                self.onError( id: id, type: type, e: error)
            }
            
        }
        self.result = .init(id: id, type:type, data: res)
    }
    private func complated<T:Decodable>(id:String, type:ApiType, res:ApiContentResponse<T>){
        let result:ApiResultResponds = .init(id: id, type:type, data: res.contents)
        let expValue = res.metadata?.exp == 0 ? nil : res.metadata?.exp
        let pointValue = res.metadata?.point == 0 ? nil : res.metadata?.point
        
        if let exp = expValue, let point = pointValue {
            self.rewardEvent = .reward(exp: exp, point: point, lvData:res.metadata)
        } else if let exp = expValue {
            self.rewardEvent = .exp(value: exp, lvData:res.metadata)
        } else if let point = pointValue {
            self.rewardEvent = .point(value: point, lvData:res.metadata)
        }
        
        switch type {
        case .joinAuth :
            if let res = result.data as? UserAuth {
                ApiNetwork.accesstoken = res.token
            }
            self.status = .ready
            self.event = .join
            
        case .reflashAuth :
            if let res = result.data as? UserAuth {
                self.initateApi(res: res)
                return
            }
        default : break
        }
        
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = result
        }
    }
    
    private func complated<T:Decodable>(id:String, type:ApiType, res:ApiItemResponse<T>){
        let result:ApiResultResponds = .init(id: id, type:type, data: res.items)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = result
        }
    }
    
    private func onError(id:String, type:ApiType, e:Error, isOptional:Bool = false, isLock:Bool = false, isProcess:Bool = false){
        if let err = e as? ApiError {
            if let res = err.response {
                switch type {
                case .reflashAuth : 
                    self.status = .error
                    self.event = .error
                    return
                default : break
                }
                
                switch res.code {
                case "C001":
                    self.apiQ.append( ApiQ(id: id, type: type, isOptional: isOptional, isLock: isLock, isProcess: isProcess) )
                    if self.status != .reflash {
                        self.status = .reflash
                        self.load(q: .init(type: .reflashAuth))
                    }
                    return
                default : break
                }
                
            }
        }
        if let trans = transition[id] {
            transition.removeValue(forKey: id)
            self.error = .init(id: id, type:trans.type, error: e, isOptional:isOptional, isProcess:isProcess)
        }else{
            self.error = .init(id: id, type:type, error: e, isOptional:isOptional, isProcess:isProcess)
        }
    }

}
