//
//  BattleShipAudio.swift
//  BattleShip
//
//  Created by Nicholas Fung on 2017-11-02.
//  Copyright © 2017 Aaron Johnson. All rights reserved.
//

import UIKit
import AVFoundation

class BattleShipAudio: NSObject {
    var player: AVAudioPlayer?
    
    func playSound(fileName:String, withExtension:String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: withExtension) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}
