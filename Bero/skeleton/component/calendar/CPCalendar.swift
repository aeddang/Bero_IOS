//
//  CPCalendar.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/08/14.
//

import Foundation
import SwiftUI

struct CPCalendar: PageComponent {
    @State private var date = Date()

    var body: some View {
        DatePicker(
            "Sesect Date",
            selection: $date,
            in: ...Date(),
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .accentColor(Color.brand.primary)
    }
}

#if DEBUG
struct CPCalendar_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            CPCalendar().contentBody
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif
