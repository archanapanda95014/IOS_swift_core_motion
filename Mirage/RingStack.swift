//
//  RingStack.swift
//  Mirage
//
//  Created by Quang Nguyen on 9/7/18.
//  Copyright © 2018 Archana Panda. All rights reserved.
//

import UIKit
import CoreMotion

extension Int {
    func randomInRange(from low: Int, to high: Int) -> Int {
        return Int(arc4random_uniform(UInt32(high - low))) + low
    }
}


class RingStack {
  var baseImageView: UIImageView
  var rings: [ImageRing] = []
  var containingView: UIView
  var colorTheme : [UIColor]
  var numRings:Int {
    return rings.count
  }
  
  init(numRings: Int, toView view: UIView,
       withBaseImage baseImage: UIImageView,
       colorTheme:[UIColor] = [.white] ) {
    self.containingView = view
    self.colorTheme = colorTheme
    self.baseImageView = baseImage
    
    for i in 0..<numRings {
      addRingFromCenter(of: containingView, withBaseImage: baseImage)
      if let thisRing = rings.last {
        thisRing.updateRadius(Double(i) * 30)
      }
    }
  }
  
  func addRingFromEdge(of view: UIView, withBaseImage imageView: UIImageView) {
    let newRing = ImageRing(
      baseImageView: imageView,
      numImage: Int(arc4random_uniform(UInt32(5))) + 5,
      radius: 400,
      center: view.center,
      imageSize: randomSize(),
      color: randomColor(),
      expandRateMultiplier: randomExpandRate(from: 1, to: 2),
      spinRate: randomSpinRate(),
      toView: view
    )
    
    rings.append(newRing)
  }
  
  func addRingFromCenter(of view: UIView, withBaseImage imageView: UIImageView) {
    
    let newRing = ImageRing(
      baseImageView: imageView,
      numImage: Int(arc4random_uniform(UInt32(5))) + 5,
      radius: 20,
      center: view.center,
      imageSize: randomSize(),
      color: randomColor(),
      expandRateMultiplier: randomExpandRate(from: 1, to: 2),
      spinRate: randomSpinRate(),
      toView: view
    )
    
    self.rings.append(newRing)
    
  }
  
  func removeRing(atIndex index: Int) {
    rings.remove(at: index)
  }
  
  // Check each ring if they have gone off the edge or collapsed at the center
  // Returns list of indexes
  func checkAndRefreshRing() {
    for i in 0..<numRings {
      
      if rings[i].tooSmall() {
        addRingFromEdge(of: containingView, withBaseImage: baseImageView)
        removeRing(atIndex: i)
        
      } else if rings[i].tooBig() {
        addRingFromCenter(of: containingView, withBaseImage: baseImageView)
        removeRing(atIndex: i)
      }
    }
  }
  
  func updateTheme(_ theme: [UIColor]) {
    self.colorTheme = theme
  }
  
  func updateBaseImage(_ newImage: UIImageView) {
    self.baseImageView = newImage
  }
  
  
  func randomSize() -> CGSize {
   
    return CGSize(width:  Int(arc4random_uniform(UInt32(55))) + 20,
                  height: Int(arc4random_uniform(UInt32(55))) + 20)
  }
  
  func randomSpinRate() -> Double {
    // randomize spinRate
    let spinRateToGetRandomly:[Double] = [0.06, 0.08, 0.11, 0.14, 0.17]
    let randIndex = Int(arc4random_uniform(UInt32(spinRateToGetRandomly.count)))
    return spinRateToGetRandomly[randIndex]
  }
  
  func randomExpandRate(from lowBound: Double, to upBound: Double) -> Double{
    // randomize expandRate
    // get a random Int from 0 to 100
    let randInt = Int(arc4random_uniform(UInt32(101)))
    // cast as double, divide by 100 multiply by total range (upbound - lowbound)
    let randDouble = Double(randInt) / 100.0 * (upBound - lowBound)
    // add to lowbound
    return lowBound + randDouble
    
  }
  
  func randomColor() -> UIColor {
    let colorsToGetRandomly = colorTheme
    let randIndex = Int(arc4random_uniform(UInt32(colorsToGetRandomly.count)))
    return colorsToGetRandomly[randIndex]
  }
  
  
}

class ImageRing {
  
  var images: [UIImageView] = []
  var numImages: Int {
    return images.count
  }
  var radius: Double
  var center: CGPoint
  var imageSize: CGSize
  var color: UIColor
  // The multiplier for how fast the ring expand/contracts
  var expandRateMultiplier: Double
  
  // Current offset of the image's position on the ring
  var currSpinOffset: Double = 0
  
  // The rate at which the images spin around the ring
  var spinRate = 0.0
  
  init(baseImageView: UIImageView,
       numImage: Int,
       radius: Double,
       center:CGPoint,
       imageSize: CGSize = CGSize(width: 50, height: 50),
       color: UIColor = .white,
       expandRateMultiplier: Double = 1,
       spinRate: Double = 0.0,
       toView view: UIView) {
    
    self.radius = radius
    self.center = center
    self.expandRateMultiplier = expandRateMultiplier
    self.spinRate = spinRate
    self.imageSize = imageSize
    self.color = color
    
    // Make images
    for i in 0..<numImage {
      let thisImage = UIImageView(image: baseImageView.image)
      let imagePos = self.imagePosition(position: i, outOf: numImage)
      thisImage.frame = CGRect(
        origin:imagePos, size: imageSize)
      
      // Debug backgorund color
      thisImage.backgroundColor = color
      
      self.images.append(thisImage)
      view.addSubview(thisImage)
    }
  }
  
  func updateRadius(_ radIncrement: Double) {
    self.radius += radIncrement
    for i in 0..<numImages {
      let imagePos = self.imagePosition(
        position: i, outOf: numImages, offSetInRadians: currSpinOffset)
      
      images[i].frame = CGRect(
        origin:imagePos, size: imageSize)
    } // endfor
  }
  
  func spin() {
    currSpinOffset += spinRate
  }
  
  
  func updateToCMData(_ data: CMDeviceMotion) {
    updateRadius(data.attitude.pitch * 10 * expandRateMultiplier)
    rotateImages(byRadians: data.attitude.pitch + Double.pi, speed: 12.0)
    updateSpin(accordingTo: data.attitude.pitch)
  }
  
  
  func updateSpin(accordingTo pitch: Double) {
    spinRate = spinRate * sin(pitch) * 3 + 0.005
  }
  
  // Return the image position for image `position` in `totalCount` images
  func imagePosition(position:Int, outOf totalCount: Int, offSetInRadians: Double = 0) -> CGPoint {
    
    return CGPoint(
      x: radius * cos(Double(position)/Double(totalCount) * 2 * Double.pi + offSetInRadians) + Double(center.x),
      y: radius * sin(Double(position)/Double(totalCount) * 2 * Double.pi + offSetInRadians) + Double(center.y)
    )
  }
  
  // Rotate each images in ring by `rotateRad` * `speed` amount
  func rotateImages(byRadians rotateRad: Double, speed: Double = 1) {
    for image in images {
      image.transform = CGAffineTransform(
        rotationAngle: CGFloat(rotateRad * speed)
      )
    }
  }
  
  func tooSmall() -> Bool {
    return radius < 10
  }
  
  func tooBig() -> Bool {
    return radius > 500
  }
  
  deinit {
    for image in self.images {
      image.removeFromSuperview()
    }
  }
  
}
