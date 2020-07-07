//
//  Recorder.swift
//  LambdaTimeline
//
//  Created by Kelson Hartle on 7/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation


protocol RecorderDelegate {
    func recorderDidChangeState(recorder: Recorder)
}

class Recorder: NSObject {
    
    private var audioRecorder: AVAudioRecorder?
    var delegate: RecorderDelegate?
    var fileURL: URL?
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    override init() {
        super.init()
    }
    
    func record() {
        // save a file in the documents directory
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("doc: \(documentDirectory)")

        let name = UUID().uuidString // "Audio"
        fileURL = documentDirectory.appendingPathComponent(name).appendingPathExtension("caf")
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        audioRecorder = try! AVAudioRecorder(url: fileURL!, format: format)
        audioRecorder?.delegate = self
        
        audioRecorder?.record()
        // start the recording
        notifyDelegate()
    }
    
    func stop() {
        audioRecorder?.stop()
        audioRecorder = nil
        notifyDelegate()
    }
    
    private func notifyDelegate() {
        delegate?.recorderDidChangeState(recorder: self)
    }
    
    func toggleRecording() {
        if isRecording {
            stop()
        } else {
            record()
        }
    }
}

extension Recorder: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error: \(error)")
        notifyDelegate()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        notifyDelegate()
    }
    
    
}
