//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



class RewardHistoryListItemData:InfinityData{
    private(set) var title:String? = nil
    private(set) var date:String? = nil
    private(set) var exp:Int = 0
    private(set) var expType:RewardApi.RewardType? = nil
    func setData(_ data:MissionData, idx:Int) -> RewardHistoryListItemData{
        self.index = idx
        let cate = MissionApi.Category.getCategory(data.missionCategory)
        switch cate {
        case .mission : self.expType = .mission
        default : self.expType = .walk
        }
        self.title = self.expType?.text
        self.date = data.createdAt?.toDate(dateFormat:"yyyy-MM-dd'T'HH:mm:ss")?.toDateFormatter(dateFormat: "EEEE, MMMM d, yyyy")
        self.exp = data.distance?.toInt() ?? 0
        return self
    }
    
    func setData(_ data:RewardHistoryData, idx:Int) -> RewardHistoryListItemData{
        self.index = idx
        self.expType = RewardApi.RewardType.getType(data.expType)
        self.title = self.expType?.text
        self.date = data.createdAt?.toDate(dateFormat:"yyyy-MM-dd'T'HH:mm:ss")?.toDateFormatter(dateFormat: "EEEE, MMMM d, yyyy")
        self.exp = data.exp?.toInt() ?? 0
        return self
    }
    
}

struct RewardHistoryListItem: PageComponent{
    @EnvironmentObject var dataProvider:DataProvider
    var data:RewardHistoryListItemData
    var body: some View {
        HistoryItem(
            id: "",
            type: .exp,
            title: self.data.title,
            date: self.data.date,
            value: self.data.exp
        )
    }
}



