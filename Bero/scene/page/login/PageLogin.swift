//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

struct PageLogin: PageView {
    @EnvironmentObject var snsManager:SnsManager
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()

    var body: some View {
        VStack(spacing: Dimen.margin.medium){
            Image(Asset.intro.onboarding_img_0)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .modifier(MatchParent())
                .frame(alignment: .top)
            
            VStack(spacing: Dimen.margin.thin){
                FillButton(
                    type: .fill,
                    icon: SnsType.apple.logo,
                    text: String.pageText.loginButtonText + SnsType.apple.title,
                    color: SnsType.apple.color
                ){_ in
                    self.snsManager.requestLogin(type: .apple)
                }
                FillButton(
                    type: .fill,
                    icon: SnsType.fb.logo,
                    text: String.pageText.loginButtonText + SnsType.fb.title,
                    color: SnsType.fb.color
                ){_ in
                    self.snsManager.requestLogin(type: .fb)
                }
                FillButton(
                    type: .stroke,
                    icon: SnsType.google.logo,
                    text: String.pageText.loginButtonText + SnsType.google.title,
                    color: SnsType.google.color
                ){_ in
                    self.snsManager.requestLogin(type: .google)
                }
            }
            .padding(.horizontal, Dimen.margin.regular)
            .padding(.top, Dimen.margin.mediumUltra)
            .padding(.bottom, Dimen.margin.medium)
        }
        .padding(.bottom, self.sceneObserver.safeAreaBottom)

        .onReceive(self.snsManager.$error){err in
            guard let err  = err  else { return }
            switch err.event {
                case .login :
                    self.appSceneObserver.alert = .alert(nil, String.alert.snsLoginError)
                case .getProfile :
                    self.join()
                default : break
            }
        }
        .onReceive(self.snsManager.$user){user in
            if user == nil { return }
            self.snsManager.getUserInfo()
            //self.appSceneObserver.event = .initate
        }
        .onReceive(self.snsManager.$userInfo){userInfo in
            if userInfo == nil { return }
            self.join(info: userInfo)
        }
        .onAppear{
            self.repository.clearLogin()
        }
    }//body
   
    private func join(info:SnsUserInfo? = nil){
        guard let user = self.snsManager.user else {
            self.appSceneObserver.alert = .alert(nil, String.alert.snsLoginError)
            return
        }
        self.repository.registerSnsLogin(user, info: info)
    }
}


#if DEBUG
struct PageLogin_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageLogin().contentBody
                .environmentObject(SnsManager())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .modifier(MatchParent())
        }
    }
}
#endif

