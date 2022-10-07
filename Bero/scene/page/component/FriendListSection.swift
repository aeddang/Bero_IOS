import Foundation
import SwiftUI

struct FriendListSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var user:User
   
    var body: some View {
        VStack(spacing:Dimen.margin.regular){
            HStack(spacing:0){
                TitleSection(
                    title: String.pageTitle.friends
                )
                SortButton(
                    type: .stroke,
                    sizeType: .big,
                    text: self.sortType.text,
                    color:Color.app.grey400,
                    isSort: true){
                        self.onSort()
                    }
                    .fixedSize()
            }
            .padding(.horizontal, Dimen.app.pageHorinzontal)
            FriendList(
                pageObservable: self.pageObservable,
                infinityScrollModel: self.infinityScrollModel,
                type:self.sortType,
                user:self.user,
                isHorizontal: true
            )
        }
        .frame(height: 230)
        
    }
    
    @State var sortType:FriendList.ListType = .friend
    private func onSort(){
        let datas:[String] = [
            FriendList.ListType.friend.text,
            FriendList.ListType.requested.text,
            FriendList.ListType.request.text
        ]
        self.appSceneObserver.radio = .sort( (self.tag, datas), title: String.pageText.walkHistorySeletReport){ idx in
            guard let idx = idx else {return}
            switch idx {
            case 0 : self.sortType = .friend
            case 1 : self.sortType = .requested
            case 2 : self.sortType = .request
            default : return
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                self.infinityScrollModel.uiEvent = .reload
            }
        }
        
    }
}


