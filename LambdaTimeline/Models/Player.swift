//
//  Player.swift
//  LambdaTimeline
//
//  Created by Kelson Hartle on 7/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlayerDelegate: AnyObject {
    func playerDidChangeState(player: Player)
}

class Player: NSObject {
    weak var delegate: PlayerDelegate?
    
    private var audioPlayer: AVAudioPlayer!
    private var timer: Timer?
    
    // Load the piano music (.mp3)
    init(url: URL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!) {
        super.init()
        
        // get the url
//        let songURL = Bundle.main.url(forResource: "piano", withExtension: "mp3")!
        audioPlayer = try! AVAudioPlayer(contentsOf: url)
        audioPlayer.delegate = self
    }
    
    // isPlaying
    // play()
    // pause()
    // playPause()
    
    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }
    
    var elapsedTime: TimeInterval {
        return audioPlayer.currentTime
    }
    
    var duration: TimeInterval {
        return audioPlayer.duration
    }
    
    func play() {
        audioPlayer.play()
        startTimer()
        notifyDelegate()
    }
    
    func pause() {
        audioPlayer.pause()
        cancelTimer()
        notifyDelegate()
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    private func notifyDelegate() {
        delegate?.playerDidChangeState(player: self)
    }
    
    private func startTimer() {
        cancelTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: updateTimer(timer:))
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer(timer: Timer) {
        notifyDelegate()
    }
    
    
}

extension Player: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        notifyDelegate()
    }
}

