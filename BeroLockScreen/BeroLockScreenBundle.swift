//
//  BeroLockScreenBundle.swift
//  BeroLockScreen
//
//  Created by JeongCheol Kim on 2022/12/24.
//

import WidgetKit
import SwiftUI

@main
struct BeroLockScreenBundle: WidgetBundle {
    var body: some Widget {
        //BeroLockScreen()
        if #available(iOS 16.1, *) {
            BeroLockScreenLiveActivity()
        }
    }
}
