//
//  VideoCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Kelson Hartle on 7/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCollectionViewCell: UICollectionViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // TODO: reset the video player.
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    var player: AVPlayer?
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    @IBOutlet weak var videoView: UIView!
    
    func loadVideo(data: Data) {
        
        let url: URL = newLocalVideoURL()
        do {
            try data.write(to: url)
            setUpPlayerAndView(with: AVPlayerItem(url: url))
        } catch {
            print("error writing to local file")
        }
        
    }
    
    private func newLocalVideoURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func setUpPlayerAndView(with playerItem: AVPlayerItem) {
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)

        playerLayer.frame = videoView.frame
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
    }
    
    
    
    
    func setupLabelBackgroundView() {
            labelBackgroundView.layer.cornerRadius = 8
    //        labelBackgroundView.layer.borderColor = UIColor.white.cgColor
    //        labelBackgroundView.layer.borderWidth = 0.5
            labelBackgroundView.clipsToBounds = true
        }

    func updateViews() {
           guard let post = post else { return }
       
           titleLabel.text = post.title
           authorLabel.text = post.author.displayName
       }
    
    
    
    
}
