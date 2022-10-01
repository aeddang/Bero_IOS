//
//  Repository.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

enum RepositoryStatus{
    case initate, ready
}

enum RepositoryEvent{
    case loginUpdate, messageUpdate(Bool)
}

class Repository:ObservableObject, PageProtocol{
    @Published var status:RepositoryStatus = .initate
    @Published var event:RepositoryEvent? = nil {didSet{ if event != nil { event = nil} }}
    let appSceneObserver:AppSceneObserver?
    let pagePresenter:PagePresenter?
    let dataProvider:DataProvider
    let networkObserver:NetworkObserver
    let shareManager:ShareManager
    let snsManager:SnsManager
    let locationObserver:LocationObserver
    let accountManager:AccountManager
    let walkManager:WalkManager
    let apiCoreDataManager = ApiCoreDataManager()
    private let storage = LocalStorage()
    private let apiManager = ApiManager()
    private var anyCancellable = Set<AnyCancellable>()
    private var dataCancellable = Set<AnyCancellable>()
     
    init(
        dataProvider:DataProvider? = nil,
        networkObserver:NetworkObserver? = nil,
        pagePresenter:PagePresenter? = nil,
        sceneObserver:AppSceneObserver? = nil,
        snsManager:SnsManager? = nil,
        locationObserver:LocationObserver? = nil,
        walkManager:WalkManager? = nil
        
    ) {
        self.dataProvider = dataProvider ?? DataProvider()
        self.networkObserver = networkObserver ?? NetworkObserver()
        self.appSceneObserver = sceneObserver
        self.pagePresenter = pagePresenter
        self.shareManager = ShareManager(pagePresenter: pagePresenter)
        self.snsManager = snsManager ?? SnsManager()
        self.locationObserver = locationObserver ?? LocationObserver()
        self.walkManager = walkManager ?? WalkManager(dataProvider: self.dataProvider, locationObserver: self.locationObserver)
        self.accountManager = AccountManager(user: self.dataProvider.user)
        self.pagePresenter?.$currentPage.sink(receiveValue: { evt in
            self.apiManager.clear()
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
            self.retryRegisterPushToken()
            if self.pagePresenter?.currentPage?.pageID == .chat {
                self.event = .messageUpdate(false)
            }
        }).store(in: &anyCancellable)
        
        self.setupSetting()
        self.setupDataProvider()
        self.setupWalkManager()
        self.setupApiManager()
        self.autoSnsLogin()
        self.updateTodayWalkCount(0)
      
    }
    
    deinit {
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
    }
    
    private func setupDataProvider(){
        self.dataProvider.$request.sink(receiveValue: { req in
            guard let apiQ = req else { return }
            if apiQ.isLock {
                self.pagePresenter?.isLoading = true
            }else if !apiQ.isOptional {
                self.appSceneObserver?.isApiLoading = true
            }
            if self.status != .initate, let coreDatakey = apiQ.type.coreDataKey() {
                self.requestApi(apiQ, coreDatakey:coreDatakey)
            }else{
                self.apiManager.load(q: apiQ)
            }
        }).store(in: &anyCancellable)
        
        self.dataProvider.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            if res.id != self.tag { return }
            switch res.type {
            case .getCode(let category, _) :
                if category == .breed {
                    SystemEnvironment.setupBreedCode(res: res)
                    self.onReady()
                }
            default : break
            }
            
        }).store(in: &anyCancellable)
    }
    
    private func setupSetting(){
        if !self.storage.initate {
            self.storage.initate = true
            SystemEnvironment.firstLaunch = true
            DataLog.d("initate APP", tag:self.tag)
        }
        self.dataProvider.user.registUser(
            id: self.storage.loginId,
            token: self.storage.loginToken,
            code: self.storage.loginType)
        
    }
    private func setupWalkManager(){
        self.walkManager.$event.sink(receiveValue: { evt in
            switch evt {
            case .completedMission :
                self.pagePresenter?.openPopup(PageProvider.getPageObject(.missionCompleted))
            case .completed :
                self.pagePresenter?.openPopup(PageProvider.getPageObject(.walkCompleted))
            default: break
            }
        }).store(in: &dataCancellable)
    }
    private func setupApiManager(){
        self.apiManager.$event.sink(receiveValue: { evt in
            switch evt {
            case .join :
                self.loginCompleted()
                self.apiManager.initateApi(user: self.dataProvider.user.snsUser)
            case .initate : self.loginCompleted()
            case .error : self.clearLogin()
            
            default: break
            }
        }).store(in: &dataCancellable)
        self.apiManager.$rewardEvent.sink(receiveValue: { evt in
            switch evt {
            case .exp(let score) :
                self.dataProvider.user.updateExp(score)
                self.appSceneObserver?.event = .check("+ exp " + score.toInt().description)
                SoundToolBox().play(snd:Asset.sound.reward)
                self.walkManager.updateReward(score, point: 0)
            case .point(let score) :
                self.dataProvider.user.updatePoint(score)
                self.appSceneObserver?.event = .check("+ point " + score.description)
                SoundToolBox().play(snd:Asset.sound.reward)
                self.walkManager.updateReward(0, point: score)
            case .reward(let exp, let point) :
                self.dataProvider.user.updateReward(exp, point: point)
                self.appSceneObserver?.event = .check("+ point " + point.description + "\n" + "+ exp " + exp.toInt().description)
                SoundToolBox().play(snd:Asset.sound.reward)
                self.walkManager.updateReward(exp, point: point)
            default: break
            }
        }).store(in: &dataCancellable)
        self.apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            self.respondApi(res)
            self.dataProvider.result = res
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
        
        }).store(in: &dataCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            self.errorApi(err)
            self.dataProvider.error = err
            if !err.isOptional {
                self.appSceneObserver?.alert = .apiError(err)
            }
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
            if err.id != self.tag { return }
            switch err.type {
            case .getCode(let category, _) :
                if category == .breed , let coreDataKey = err.type.coreDataKey() {
                    if let savedData:[CodeData] = self.apiCoreDataManager.getData(key: coreDataKey){
                        SystemEnvironment.setupBreedCode(datas: savedData)
                    }
                    self.onReady()
                }
            default : break
            }
            
        }).store(in: &dataCancellable)
        
    }
    
    private func requestApi(_ apiQ:ApiQ, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            var coreData:Codable? = nil
            switch apiQ.type {
                case .getCode :
                    if let savedData:[CodeData] = self.apiCoreDataManager.getData(key: coreDatakey){
                        coreData = savedData
                    }
                default: break
            }
            DispatchQueue.main.async {
                if let coreData = coreData {
                    self.dataProvider.result = ApiResultResponds(id: apiQ.id, type: apiQ.type, data: coreData)
                    self.appSceneObserver?.isApiLoading = false
                    self.pagePresenter?.isLoading = false
                }else{
                    self.apiManager.load(q: apiQ)
                }
            }
        }
    }
    private func respondApi(_ res:ApiResultResponds){
        self.accountManager.respondApi(res, appSceneObserver: self.appSceneObserver)
        self.walkManager.respondApi(res)
        switch res.type {
        case .registPush(let token) : self.registedPushToken(token)
        case .getChatRooms(let page, _) : if page == 0 { self.onMassageUpdated(res) }
        default : break
        }
        if let coreDatakey = res.type.coreDataKey(){
            self.respondApi(res, coreDatakey: coreDatakey)
        }
    }
    private func errorApi(_ err:ApiResultError){
        self.accountManager.errorApi(err, appSceneObserver: self.appSceneObserver)
        self.walkManager.errorApi(err, appSceneObserver: self.appSceneObserver)
        switch err.type {
        case .joinAuth : self.clearLogin()
        case .registPush(let token) : self.registFailPushToken(token)
        default : break
        }
    }
    private func respondApi(_ res:ApiResultResponds, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            switch res.type {
                case .getCode :
                    guard let data = res.data as? [CodeData]  else { return }
                    self.apiCoreDataManager.setData(key: coreDatakey, data: data)
                default: break
            }
        }
    }
    

    func registerSnsLogin(_ user:SnsUser, info:SnsUserInfo?) {
        self.storage.loginId = user.snsID
        self.storage.loginToken = user.snsToken
        self.storage.loginType = user.snsType.apiCode()
        self.dataProvider.user.registUser(user: user)
        self.dataProvider.requestData(q: .init(type: .joinAuth(user, info)))
    }
    func clearLogin() {
        self.storage.loginId = nil
        self.storage.loginToken = nil
        self.storage.loginType = nil
        self.storage.authToken = nil
        self.apiManager.clearApi()
        self.dataProvider.user.clearUser()
        self.snsManager.requestAllLogOut()
        self.event = .loginUpdate
        self.status = .ready
        self.retryRegisterPushToken()
    }
    
    private func autoSnsLogin() {
        if let user = self.dataProvider.user.snsUser , let token = self.storage.authToken {
            self.apiManager.initateApi(token: token, user: user)
        } else {
            self.clearLogin()
        }
    }
    
    private func loginCompleted() {
        self.storage.authToken = ApiNetwork.accesstoken
        self.event = .loginUpdate
        self.dataProvider.requestData(q: .init(id: self.tag, type: .getCode(category: .breed)))
 
    }
    private func onReady() {
        self.storage.authToken = ApiNetwork.accesstoken
        self.status = .ready
        if let user = self.dataProvider.user.snsUser {
            self.dataProvider.requestData(q: .init(type: .getUser(user, isCanelAble: false), isOptional: true))
            self.dataProvider.requestData(q: .init(type: .getPets(user, isCanelAble: false), isOptional: true))
            self.dataProvider.requestData(q: .init(id: self.tag, type: .getChatRooms(page: 0), isOptional: true))
        }
        self.retryRegisterPushToken()
        
    }
    var isLogin: Bool {
        self.storage.authToken?.isEmpty == false
    }
    
    func updateTodayWalkCount(_ diff:Int = 1){
        var count = diff
        let now = AppUtil.networkTimeDate().toDateFormatter(dateFormat: "yyyyMMdd")
        if let pre = self.storage.walkCount {
            if pre.hasPrefix(now) {
                let preCount = pre.replace(now, with:"").toInt()
                if preCount != -1 {
                    count = count + preCount
                }
            }
        }
        self.storage.walkCount = now + count.description
        WalkManager.todayWalkCount = count
    }
    
    //Message
    func onMassageUpdated(_ res:ApiResultResponds){
        if res.id != self.tag { return }
        guard let datas = res.data as? [ChatData] else { return }
        let find = datas.first(where: {$0.isRead == false})
        self.event = .messageUpdate(find != nil)
    }
    
    
    // PushToken
    func retryRegisterPushToken(){
        if !self.storage.retryPushToken.isEmpty{
            DataLog.d("retryRegisterPushToken " + self.storage.retryPushToken, tag:self.tag)
            self.registPushToken(self.storage.retryPushToken)
        }
    }
    func onCurrentPushToken(_ token:String) {
        if self.storage.registPushToken == token {return}
        DataLog.d("onCurrentPushToken", tag:self.tag)
        switch self.status {
        case .initate :  self.storage.retryPushToken = token
        case .ready : self.registPushToken(token)
        }
    }
    
    private func registPushToken(_ token:String) {
        self.storage.retryPushToken = ""
        self.storage.registPushToken = token
        self.dataProvider.requestData(q: .init(type: .registPush(token: token), isOptional: true))
    }
    private func registedPushToken(_ token:String) {
        
        DataLog.d("registedPushToken", tag:self.tag)
    }
    private func registFailPushToken(_ token:String) {
        self.storage.retryPushToken = token
        self.storage.registPushToken = ""
        DataLog.d("registFailPushToken", tag:self.tag)
    }
}
