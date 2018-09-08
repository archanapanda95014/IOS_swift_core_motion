//
//  ViewController.swift
//  Mirage
//
//  Created by Archana Panda on 9/6/18.
//  Copyright © 2018 Archana Panda. All rights reserved.
//

import UIKit
import CoreMotion




class ViewController: UIViewController {
  
  @IBOutlet var imageList: [UIImageView]!
  
  @IBAction func themeButtonPressed(_ sender: UIButton) {
    for ringStack in ringStacks {
      ringStack.updateTheme(themeList[themeCycle])
    }
    
    themeCycle += 1
    if themeCycle > themeList.count - 1 {
      themeCycle = 0
    }
    
  }
  
  @IBAction func imgButtonPressed(_ sender: UIButton) {
    for ringStack in ringStacks {
      ringStack.updateBaseImage(imageList[imgCycle])
    }
    
    imgCycle += 1
    if imgCycle > imageList.count - 1 {
      imgCycle = 0
    }
  }
  
  func shuffleRingStack() {
    themeCycle = Int(arc4random_uniform(UInt32(themeList.count)))
    imgCycle = Int(arc4random_uniform(UInt32(imageList.count)))
    
    for ringStack in ringStacks {
      ringStack.updateTheme(themeList[themeCycle])
      ringStack.updateBaseImage(imageList[imgCycle])
    }
  }
  
  var ringStacks:[RingStack] = []
  var themeCycle = 0
  var imgCycle = 0
  
  var motionManager = CMMotionManager()
  let opQueue = OperationQueue()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let mainView = view else {
      return
    }
    
    ringStacks.append(
      RingStack(numRings: 6, toView: mainView,
        withBaseImage: imageList[0], colorTheme: primaryTheme)
//      RingStack(numRings: 3, toView: mainView,
//        withBaseImage: butterfly, colorTheme: pastelsTheme),
      )
    
    for image in imageList {
      image.isHidden = true
    }
    if motionManager.isDeviceMotionAvailable {
      print("We can detect device motion")
      startReadingMotionData(for: ringStacks)
    }
    else {
      print("We cannot detect device motion")
    }
    
    isPlaying = true
    btwPlayer?.numberOfLoops = -1
    playSound("theme")
  }

  
  func startReadingMotionData(for ringStacks: [RingStack]) {
    // set read speed
    motionManager.deviceMotionUpdateInterval = Double(1/24)
    // start reading
    motionManager.startDeviceMotionUpdates(to: opQueue) { (data: CMDeviceMotion?, error: Error?) in
      
      guard let mydata = data else {
        return
      }
      
      
      if (mydata.attitude.roll > 9.0/10.0 * Double.pi
        && mydata.attitude.roll < 11.0/10.0 * Double.pi){
        print("ROLLED")
        self.shuffleRingStack()
      }
      
      // Send to main thread
      DispatchQueue.main.async {
        
        for ringStack in ringStacks {
          ringStack.checkAndRefreshRing()
          for i in 0..<ringStack.numRings {
            ringStack.rings[i].updateToCMData(mydata)
            ringStack.rings[i].spin()
          }
        }
      }
    
    }
  }
  
  func degrees(_ radians: Double) -> Double {
    return 180/Double.pi * radians
  }
  
  
}



