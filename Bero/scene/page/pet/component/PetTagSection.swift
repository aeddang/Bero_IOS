import Foundation
import SwiftUI

struct PetTagSection: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var profile:PetProfile
    var listSize:CGFloat = 300
    var body: some View {
        VStack(alignment: .leading, spacing:Dimen.margin.regularExtra){
            TitleTab(type:.section, title: String.pageTitle.tag, buttons:self.profile.isMypet ? [.edit] : []){ type in
                switch type {
                case .edit :
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.editProfile)
                            .addParam(key: .data, value: self.profile)
                            .addParam(key: .type, value: PageEditProfile.EditType.hash)
                    )
                default : break
                }
                
            }
            VStack(alignment: .leading, spacing:Dimen.margin.tiny){
                ForEach(self.buttonSets) { data in
                    HStack(alignment: .center, spacing: Dimen.margin.thin) {
                        ForEach(data.cells) { cell in
                            SortButton(
                                type: .strokeFill,
                                sizeType: .big,
                                text: cell.title,
                                color:Color.brand.primary ,
                                isSort: false){
                                    
                                }
                                .fixedSize()
                        
                        }
                    }
                }
            }
        }
        .onReceive(self.profile.$hashStatus){ status in
            guard let status = status else {return}
            self.selects = PetProfile.exchangeStringToList(status)
            self.dataProvider.requestData(q: .init(id: self.tag, type: .getCode(category: .personality)))
        }
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            if !res.id.hasPrefix(self.tag) {return}
            switch res.type {
            case .getCode(let category,_):
                if category != .personality {return}
                self.setupCode(res, category: category)
                self.setupData()
            default : break
            }
        }
    }
    
    @State var buttons:[RadioBtnData] = []
    @State var buttonSets:[HashRows] = []
    @State var selects:[String] = []
    
    private func setupCode(_ res:ApiResultResponds,  category:MiscApi.Category){
        guard let datas = res.data as? [CodeData] else { return }
        var index:Int = 0
        self.buttons = datas.filter{ data in
            let id = data.id?.description ?? ""
            return self.selects.first(where: {$0==id}) != nil
            
        }.map{ data in
            let num = index
            index += 1
            return RadioBtnData(
                title: data.value ?? "",
                value: data.id?.description,
                index: num
            )
        }
    }
    struct HashRows:Identifiable{
        let id = UUID().uuidString
        let idx:Int
        var cells:[RadioBtnData]
    }
    private func setupData(){
        var rows:[HashRows] = []
        var cells:[RadioBtnData] = []
        var lineWidth:CGFloat = 0
        let lineLimit = self.listSize
        let margin = SortButton.SizeType.big.marginHorizontal * 2
        let font = SemiBoldTextStyle(size: SortButton.SizeType.big.textSize).textModifier
        self.buttons.forEach{ d in
            let btnWidth = font.getTextWidth(d.title) + margin
            let willSize = lineWidth + btnWidth
            //PageLog.d(d.title + " -> " + btnWidth.description, tag: self.tag )
            //PageLog.d("willSize -> " + willSize.description, tag: self.tag )
            if lineLimit >= willSize {
                cells.append(d)
                lineWidth += (btnWidth + Dimen.margin.thin)
            }else{
                rows.append(HashRows(idx:rows.count, cells: cells))
                cells = [d]
                lineWidth = (btnWidth + Dimen.margin.thin)
            }
        }
        if !cells.isEmpty {
            rows.append(HashRows(idx:rows.count, cells: cells))
        }
        self.buttonSets = rows
    }
   
}


