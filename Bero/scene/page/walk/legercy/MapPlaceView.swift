//
//  MapPlaceView.swift
//  Bero
//
//  Created by JeongCheol Kim on 2023/02/12.
//

import Foundation
import UIKit

class MapPlaceView :UIView {
    @IBOutlet var title:UILabel? = nil
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bindingXib()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.bindingXib()
    }
    private func bindingXib(){
        let view = Bundle.main.loadNibNamed("MapPlaceView", owner: self)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    func setData(_ data:Place){
        self.title?.text = data.title
    }
}
