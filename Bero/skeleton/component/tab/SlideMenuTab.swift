//
//  SlideMenuTab.swift
//  Bero
//
//  Created by JeongCheol Kim on 2022/07/31.
//

import Foundation
import SwiftUI
struct SlideMenuTab : PageComponent {
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:NavigationModel = NavigationModel()
 
    var buttons:[String]
    var selectedIdx:Int = 0
    
    var color:Color = Color.brand.primary
    var bgColor:Color = Color.transparent.clearUi
    var height:CGFloat = Dimen.button.regular
    var isDivision:Bool = true
    @State var menus:[NavigationButton] = []
   
    var body: some View {
        ZStack(){
            if isDivision {
                CPTabDivisionNavigation (
                    buttons:
                        NavigationBuilder(index:self.selectedIdx)
                        .getNavigationButtons(texts:self.buttons)
                )
                .frame(height: self.height)
            } else {
                CPTabNavigation(
                    buttons:
                        NavigationBuilder(index:self.selectedIdx, marginVertical: Dimen.margin.thin)
                        .getNavigationButtons(texts:self.buttons)
                )
                .frame(height: self.height)
            }
        }
       
        .background(self.bgColor)
        .onAppear(){
            
        }
        
    }//body
}

#if DEBUG
struct SlideMenuTab_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            SlideMenuTab(
                viewModel:NavigationModel(),
                buttons: [
                    "Animal ID", "Animal ID", "Animal ID"
                ],
                isDivision: true
            )
            SlideMenuTab(
                viewModel:NavigationModel(),
                buttons: [
                    "Animal ID", "Animal ID", "Animal ID"
                ],
                selectedIdx : 2,
                isDivision: false
            )
            
           
        }
        .background(Color.app.white)
    }
}
#endif
