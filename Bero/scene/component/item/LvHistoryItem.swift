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
    private(set) var value:Int = 0
    private(set) var valueType:HistoryItem.HistoryType = .exp
    private(set) var rewardType:RewardApi.RewardType? = nil
    func setData(_ data:MissionData, idx:Int) -> RewardHistoryListItemData{
        self.index = idx
        let cate = MissionApi.Category.getCategory(data.missionCategory)
        switch cate {
        case .mission : self.rewardType = .mission
        default : self.rewardType = .walk
        }
        self.title = self.rewardType?.text
        self.date = data.createdAt?.toDate()?.toDateFormatter(dateFormat: "MMMM d, yyyy")
        self.value = data.distance?.toInt() ?? 0
        return self
    }
    
    func setData(_ data:RewardHistoryData, type:HistoryItem.HistoryType = .exp, idx:Int) -> RewardHistoryListItemData{
        self.index = idx
        self.rewardType = RewardApi.RewardType.getType(data.expType)
        self.title = self.rewardType?.text
        self.date = data.createdAt?.toDate()?.toDateFormatter(dateFormat: "MMMM d, yyyy")
        self.valueType = type
        switch self.valueType {
        case .exp :
            self.value = data.exp?.toInt() ?? 0
        case .point :
            self.value = data.point?.toInt() ?? 0
        default :
            self.value = 0
        }
        return self
    }
    
}

struct RewardHistoryListItem: PageComponent{
    @EnvironmentObject var dataProvider:DataProvider
    var data:RewardHistoryListItemData
    
    var body: some View {
        HistoryItem(
            id: "",
            type: self.data.valueType,
            title: self.data.title,
            date: self.data.date,
            value: self.data.value
        )
    }
}



