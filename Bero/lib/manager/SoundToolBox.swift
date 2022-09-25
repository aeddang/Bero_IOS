//
//  SoundBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/15.
//

import Foundation
import SwiftUI
import UIKit
import AudioToolbox

class SoundToolBox {
    private static var registSound:[String: SystemSoundID] = [:]
    
    func play(snd:String, ext:String = "mp3") {
        if let sid = Self.registSound[snd] {
            AudioServicesPlayAlertSoundWithCompletion(sid){}
            
        } else {
           
            guard let url = Bundle.main.url(forResource: snd, withExtension: ext) else {return}
            var sound: SystemSoundID = SystemSoundID(Self.registSound.count)
            let result = AudioServicesCreateSystemSoundID(url as CFURL, &sound)
           
            Self.registSound[snd] = sound
            AudioServicesPlayAlertSound(sound)
        }
        
    }

}
