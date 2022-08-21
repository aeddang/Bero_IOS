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
    case loginUpdate
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
        }).store(in: &anyCancellable)
        
        self.setupSetting()
        self.setupDataProvider()
        self.setupWalkManager()
        self.setupApiManager()
        self.status = .ready
        self.autoSnsLogin()
      
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
            }else{
                self.appSceneObserver?.isApiLoading = true
            }
            if let coreDatakey = apiQ.type.coreDataKey(){
                self.requestApi(apiQ, coreDatakey:coreDatakey)
            }else{
                self.apiManager.load(q: apiQ)
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
        
        if self.storage.retryPushToken != "" {
            self.registerPushToken(self.storage.retryPushToken)
        }
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
        self.apiManager.$event.sink(receiveValue: { status in
            switch status {
            case .join :
                self.loginCompleted()
                self.apiManager.initateApi(user: self.dataProvider.user.snsUser)
            case .initate : self.loginCompleted()
            case .error : self.clearLogin()
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
        self.accountManager.respondApi(res)
        self.walkManager.respondApi(res)
        if let coreDatakey = res.type.coreDataKey(){
            self.respondApi(res, coreDatakey: coreDatakey)
        }
    }
    private func errorApi(_ err:ApiResultError){
        self.accountManager.errorApi(err, appSceneObserver: self.appSceneObserver)
        self.walkManager.errorApi(err, appSceneObserver: self.appSceneObserver)
        switch err.type {
        case .joinAuth : self.clearLogin()
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
    // PushToken
    func retryRegisterPushToken(){
        if self.storage.retryPushToken != "" {
            self.registerPushToken(self.storage.retryPushToken)
        }
    }
    
    func registerPushToken(_ token:String) {
        self.storage.retryPushToken = token
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
        if let user = self.dataProvider.user.snsUser {
            self.dataProvider.requestData(q: .init(type: .getUser(user, isCanelAble: false), isOptional: true))
            self.dataProvider.requestData(q: .init(type: .getPets(user, isCanelAble: false), isOptional: true))
        }
    }
    var isLogin: Bool {
        self.storage.authToken?.isEmpty == false
    }
   
}
