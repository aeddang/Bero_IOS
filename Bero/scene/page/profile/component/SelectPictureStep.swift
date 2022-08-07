//
//  TitleTab.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/20.
//

//
//  PageTab.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI




struct SelectPictureStep: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    let profile:ModifyPetProfileData?
    let step:PageAddDog.Step
    let prev: (() -> Void)
    let next: ((ModifyPetProfileData) -> Void)
   
    @State var picture:UIImage? = nil
    var body: some View {
        VStack(spacing: Dimen.margin.tiny){
            ProfileImage(
                id : "",
                image: self.picture ,
                isSelected: self.picture != nil,
                size: Dimen.profile.heavy,
                emptyImagePath: Asset.image.profile_dog_default,
                onDelete: {
                    self.picture = nil
                }
            )
            .padding(.bottom, Dimen.margin.regular)
            SelectButton(
                type: .small,
                icon: Asset.icon.album,
                text: String.button.album
            ){_ in
                self.appSceneObserver.event = .openImagePicker(self.tag, type: .photoLibrary){ pick in
                    guard let pick = pick else {return}
                    self.picture = pick
                }
            }
            SelectButton(
                type: .small,
                icon: Asset.icon.album,
                text: String.button.camera
            ){_ in
                self.appSceneObserver.event = .openImagePicker(self.tag, type: .camera){ pick in
                    guard let pick = pick else {return}
                    self.picture = pick
                }
            }
            Spacer()
            HStack (spacing:Dimen.margin.tinyExtra){
                if !self.step.isFirst {
                    FillButton(
                        type: .fill,
                        text: String.button.goBack,
                        color: Color.app.grey50,
                        textColor: Color.app.grey400
                    ){_ in
                        self.prev()
                    }
                }
                FillButton(
                    type: .fill,
                    text: String.button.next,
                    color:Color.app.white,
                    gradient: Color.app.orangeGradient
                ){_ in
                    if self.picture == nil {return}
                    self.next(
                        .init(
                            image: self.picture
                        )
                    )
                }
                .modifier(Shadow())
                .opacity(self.picture == nil ? 0.3 : 1)
            }
        }
        
        .onAppear{
            self.picture = self.profile?.image
        }
    }
}

#if DEBUG
struct SelectPictureStep_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack{
            SelectPictureStep(
                profile: .init(),
                step: .picture,
                prev: {},
                next: { data in }
            )
            .environmentObject(PagePresenter()).frame(width:320,height:600)
                
        }
    }
}
#endif

