//
//  heart.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/09/09.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

class VissionApi :Rest{
    func post(img:UIImage, action:ApiAction, completion: @escaping (ApiContentResponse<DetectData>) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: VissionImagesApiRoute(method: .post, action: action),
           constructingBlock:{ data in
            if let value = img.jpegData(compressionQuality: 1.0) {
                data.append(file: value,name: "contents",fileName: "visionImage.jpg",mimeType:"image/jpeg")
            }
        }, completion: completion, error:error)
    }
}

struct VissionImagesApiRoute : ApiRoute{
    var method:HTTPMethod = .post
    var command: String = "vision/images"
    var action: ApiAction? = nil
    var commandId: String? = nil
    var query:[String: String]? = nil
    var body:[String: Any]? = nil
    var overrideHeaders: [String : String]? = nil
}

