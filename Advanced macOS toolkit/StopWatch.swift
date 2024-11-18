//
//  StopWatch.swift
//  CuckooClock
//
//  Created by Gruia Chiscop on 9/14/24.
//

import Foundation
import AVFoundation

class StopWatch {
    var timer: Timer?
    var interval: TimeInterval
    var sound: String
    var player: AVAudioPlayer?
    init(_ sound: String, interval: Int = 3600) {
        self.sound = sound
        self.interval = TimeInterval(interval)
    }
    
    func loadSound() {
        if let url = Bundle.main.url(forResource: sound, withExtension: "wav") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
            } catch {
                print("Unable to load the sound!")
            }
        }
        }
        
        @objc func ring() {
            player?.prepareToPlay()
            player?.play()
        }
        
        func stop() {
            timer?.invalidate()
        }
        
        func start() {
            stop()
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval * 60), target: self, selector: #selector(ring), userInfo: nil, repeats: true)
    }
}
