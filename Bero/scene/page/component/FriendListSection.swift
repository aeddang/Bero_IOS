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
                    title: self.sortType.text
                )
                ImageButton(
                    defaultImage: self.sortType == .friend ? Asset.icon.add_friend : Asset.icon.my,
                    iconText:self.hasRequested && self.sortType == .friend ? "N" : nil
                ){ _ in
                    switch self.sortType {
                    case .friend : self.sortType = .requested
                    default : self.sortType = .friend
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                        self.infinityScrollModel.uiEvent = .reload
                    }
                }
                /*
                SortButton(
                    type: .stroke,
                    sizeType: .big,
                    text: self.sortType.text,
                    color:Color.app.grey400,
                    isSort: true){
                        self.onSort()
                    }
                    .fixedSize()
                 */
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
        .frame(height: 190)
        .onReceive(self.dataProvider.$result){res in
            guard let res = res else { return }
            if res.id != self.tag {return}
            switch res.type {
            case .getRequestedFriend :
                guard let datas = res.data as? [FriendData] else { return }
                self.hasRequested = !datas.isEmpty
                
            default : break
            }
        }
        .onAppear(){
            self.dataProvider.requestData(q: .init(id: self.tag, type:.getRequestedFriend(page: 0)))
        }
    }
    @State var hasRequested:Bool = false
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


