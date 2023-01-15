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
    @State var isShowing = false
    var body: some View {
        VStack(spacing: Dimen.margin.tiny){
            ProfileImage(
                id : "",
                image: self.picture ,
                isSelected: self.picture != nil,
                size: Dimen.profile.heavy,
                emptyImagePath: Asset.image.profile_dog_default
            )
            .padding(.bottom, Dimen.margin.regular)
            SelectButton(
                type: .small,
                icon: Asset.icon.album,
                text: String.button.selectAlbum
            ){_ in
                self.appSceneObserver.event = .openImagePicker(self.tag, type: .photoLibrary){ pick in
                    guard let pick = pick else {return}
                    self.picture = pick
                }
            }
            SelectButton(
                type: .small,
                icon: Asset.icon.add_photo,
                text: String.button.takeCamera
            ){_ in
                self.appSceneObserver.event = .openImagePicker(self.tag, type: .camera){ pick in
                    guard let pick = pick else {return}
                    DispatchQueue.global(qos:.background).async {
                        let scale:CGFloat = 1 //UIScreen.main.scale
                        let sizeList = CGSize(
                            width: AlbumApi.thumbSize * scale,
                            height: AlbumApi.thumbSize * scale)
                        let thumbImage = pick.normalized().crop(to: sizeList).resize(to: sizeList)
                        DispatchQueue.main.async {
                            self.pagePresenter.isLoading = false
                            self.picture = thumbImage
                        }
                    }
                    
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
        .opacity(self.isShowing ? 1 : 0)
        .onAppear{
            self.picture = self.profile?.image
            withAnimation{  self.isShowing = true }
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

