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
    @State var isAgree:Bool = false
    var body: some View {
        VStack(spacing: Dimen.margin.medium){
            ZStack(alignment: .top){
                Image(Asset.intro.onboarding_img_0)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .modifier(MatchParent())
                    .frame(alignment: .top)
                Text(String.pageText.loginText)
                    .modifier( BoldTextStyle(
                        size: Font.size.black,
                        color:  Color.app.black
                    ))
                    .multilineTextAlignment(.center)
                    .fixedSize()
                    .padding(.top, 60)
            }
            VStack(spacing: Dimen.margin.thin){
                AgreeButton(
                    type: .service,
                    isChecked: self.isAgree
                ){ _ in
                    self.isAgree.toggle()
                }
                FillButton(
                    type: .fill,
                    icon: SnsType.apple.logo,
                    text: String.pageText.loginButtonText + SnsType.apple.title,
                    color: SnsType.apple.color
                ){_ in
                    
                    if !self.isAgree {return}
                    self.snsManager.requestLogin(type: .apple)
                }
                .opacity(self.isAgree ? 1 : 0.5)
                
                FillButton(
                    type: .fill,
                    icon: SnsType.fb.logo,
                    text: String.pageText.loginButtonText + SnsType.fb.title,
                    color: SnsType.fb.color
                ){_ in
                    if !self.isAgree {
                        self.appSceneObserver.event = .toast(String.alert.needAgreement)
                        return
                        
                    }
                    self.snsManager.requestLogin(type: .fb)
                }
                .opacity(self.isAgree ? 1 : 0.5)
                FillButton(
                    type: .stroke,
                    icon: SnsType.google.logo,
                    text: String.pageText.loginButtonText + SnsType.google.title,
                    color: SnsType.google.color
                ){_ in
                    if !self.isAgree {
                        self.appSceneObserver.event = .toast(String.alert.needAgreement)
                        return
                    }
                    self.snsManager.requestLogin(type: .google)
                }
                .opacity(self.isAgree ? 1 : 0.5)
            }
            .padding(.horizontal, Dimen.margin.regular)
            .padding(.top, Dimen.margin.heavyExtra)
            .padding(.bottom, Dimen.margin.medium)
        }
        .padding(.bottom, self.appSceneObserver.safeBottomHeight)
        .modifier(MatchParent())
        .background(Color.brand.bg)

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

