//
//  DeviceMotionObserver.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/03/02.
//

import Foundation
import CoreMotion

class DeviceMotionObserver: NSObject, ObservableObject {
    
    private let  motionManager = CMMotionManager()
    private(set) var isSearch:Bool = false
    private(set) var requestId:String? = nil
    private let queue = OperationQueue()
    @Published private(set) var rotation:Double = 0
    
    override init() {
        super.init()
        
    }
    deinit {
        self.motionManager.stopGyroUpdates()
        self.motionManager.stopDeviceMotionUpdates()
        self.motionManager.stopMagnetometerUpdates()
        self.motionManager.stopAccelerometerUpdates()
    }
    
    
    
    func startRotation(){
        var crt = self.rotation
        self.motionManager.startDeviceMotionUpdates(to: queue) {
          [weak self] (data: CMDeviceMotion?, error: Error?) in
            guard let self = self else {return}
              if let gravity = data?.gravity {
                  let rt = atan2(gravity.x, gravity.y) - .pi
                  let diff = abs(rt-crt)
                  if diff <= 0.1 {
                      return
                  }
                  crt = rt
                 
                  DispatchQueue.main.async {
                      self.rotation = rt
                      DataLog.d("rt " + rt.description, tag: "DeviceMotionUpdates")
                      DataLog.d("diff " + diff.description, tag: "DeviceMotionUpdates")
                  }
                 
              }
        }
    }
    func stopRotation(){
        self.motionManager.stopDeviceMotionUpdates()
    }
}
