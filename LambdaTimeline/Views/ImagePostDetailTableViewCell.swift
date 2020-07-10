//
//  ImagePostDetailTableViewCell.swift
//  LambdaTimeline
//
//  Created by Kelson Hartle on 7/3/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation


protocol ImagePostDetailTableViewCellDelegate {
    func playAudioButtonWasTapped(data: Data)
}

class ImagePostDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var commentText: UILabel!
    @IBOutlet weak var commentAuthor: UILabel!
    @IBOutlet weak var playAudioButton: UIButton!
    
    
    private var audioData: Data?
    var delegate: ImagePostDetailTableViewCellDelegate?
    
    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    
    func setAudioData(data: Data?) {
        audioData = data
    }

    private func updateViews() {
        guard let comment = comment else { return }

        if let title = comment.text {
            commentText.text = title
        } else {
            commentText.isHidden = true
        }

        commentAuthor.text = comment.author.displayName

        if comment.audioURL == nil {
            playAudioButton.isHidden = true
        }
    }

    private func playAudioData() {
        if let audioData = audioData {
            delegate?.playAudioButtonWasTapped(data: audioData)
        }
    }
    
    
    @IBAction func playAudioDataTapped(_ sender: Any) {
        playAudioData()
    }
}
