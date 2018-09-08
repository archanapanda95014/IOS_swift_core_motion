//
//  audio.swift
//  Mirage
//
//  Created by Quang Nguyen on 9/7/18.
//  Copyright © 2018 Archana Panda. All rights reserved.
//

import AVFoundation

var btwPlayer: AVAudioPlayer?

var neutral = false
var isPlaying: Bool = true

func playSound(_ name: String) {
  
  guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
    print("CANT FIND URL")
    return }
  do {
    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    try AVAudioSession.sharedInstance().setActive(true)
    // The following line is required for the player to work on iOS 11. Change the file type accordingly
    btwPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
    // iOS 10 and earlier require the following line:
    //            btwPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
    guard let player = btwPlayer else {
      print("NOPE")
      return
      
    }
    
    if isPlaying == true {
      player.play()
    }
    else {
      player.stop()
    }
  } catch {
    //            print(error.localizedDescription)
  }
}
