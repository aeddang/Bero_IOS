//
//  TextButton.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



class LvHistoryListItemData:InfinityData{
    private(set) var title:String? = nil
    private(set) var date:String? = nil
    private(set) var exp:Int = 0
    func setData(_ data:MissionData, idx:Int) -> LvHistoryListItemData{
        self.index = idx
        self.title = data.missionCategory
        self.date = data.createdAt?.toDate(dateFormat:"yyyy-MM-dd'T'HH:mm:ss")?.toDateFormatter(dateFormat: "EEEE, MMMM d, yyyy")
        self.exp = data.distance?.toInt() ?? 0
        return self
    }
    
}

struct LvHistoryListItem: PageComponent{
    @EnvironmentObject var dataProvider:DataProvider
    var data:LvHistoryListItemData
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



