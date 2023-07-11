//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAnalytics

struct PageLogin: PageView {
    @EnvironmentObject var snsManager:SnsManager
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @State var isAgree:Bool = true
    var body: some View {
        VStack(spacing: 0){
            ZStack(alignment: .center){
                Circle()
                    .fill(
                        RadialGradient(gradient: Gradient(
                            colors: [Color.app.orangeSub.opacity(0.3), Color.app.orangeSub.opacity(0)]), center: .center, startRadius: 0, endRadius: 100)
                    )
                    .modifier(MatchParent())
                Image(Asset.splashLogo)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 142)
            }
            .padding(.top, self.appSceneObserver.safeHeaderHeight)
            .modifier(MatchParent())
            .layoutPriority(0)
            VStack(spacing: Dimen.margin.mediumUltra){
                Text(String.pageText.loginText0)
                    .modifier( RegularTextStyle(
                        size: Font.size.light,
                        color:  Color.app.grey500
                    ))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.regular)
                
                Text(String.pageText.loginText1)
                    .modifier( SemiBoldTextStyle(
                        size: Font.size.medium,
                        color:  Color.app.black
                    ))
                    .multilineTextAlignment(.center)
                    
                /*
                AgreeButton(
                    type: .service,
                    isChecked: self.isAgree
                ){ _ in
                    self.isAgree.toggle()
                }
                */
                VStack(spacing: Dimen.margin.thin){
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
                }
                
                VStack(spacing: 0){
                    Text("By continuing, you agree to Bero’s ")
                        .font(.custom(Font.family.light,size: Font.size.thin))
                        .foregroundColor(Color.app.grey500)
                    HStack(spacing: 0){
                        Text(AgreeButton.ButtonType.service.text)
                            .font(.custom(Font.family.regular,size: Font.size.thin))
                            .foregroundColor(Color.app.black)
                            .underline(true)
                            .onTapGesture {
                                guard let page = AgreeButton.ButtonType.service.page else {return}
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(page)
                                )
                                let parameters = [
                                    "buttonType": self.tag,
                                    "buttonText": AgreeButton.ButtonType.service.text  + " more"
                                ]
                                Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
                            }
                        Text(" and ")
                            .font(.custom(Font.family.light,size: Font.size.thin))
                            .foregroundColor(Color.app.grey500)
                        Text(AgreeButton.ButtonType.privacy.text)
                            .font(.custom(Font.family.regular,size: Font.size.thin))
                            .foregroundColor(Color.app.black)
                            .underline(true)
                            .onTapGesture {
                                guard let page = AgreeButton.ButtonType.privacy.page else {return}
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(page)
                                )
                                let parameters = [
                                    "buttonType": self.tag,
                                    "buttonText": AgreeButton.ButtonType.privacy.text  + " more"
                                ]
                                Analytics.logEvent(AnalyticsEventSelectItem, parameters:parameters)
                            }
                        Text(".")
                            .font(.custom(Font.family.light,size: Font.size.thin))
                            .foregroundColor(Color.app.grey500)
                    }
                }
                
                
            }
            .padding(.bottom, self.appSceneObserver.safeBottomHeight)
            .modifier(BottomFunctionTab())
            .layoutPriority(1)
        }
        .modifier(MatchParent())
        .background(Color.brand.primary)

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

