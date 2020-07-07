//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController {
    
    override func viewDidLoad() {
            super.viewDidLoad()
            updateViews()
        }
        
        func updateViews() {
            
            guard let imageData = imageData,
                let image = UIImage(data: imageData) else { return }
            
            title = post?.title
            
            imageView.image = image
            
            titleLabel.text = post.title
            authorLabel.text = post.author.displayName
        }
        
        // MARK: - Table view data source
        
        @IBAction func createComment(_ sender: Any) {
            
            let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)

            var commentTextField: UITextField?
            
            alert.addTextField { (textField) in
                textField.placeholder = "Comment:"
                commentTextField = textField
            }
            
            let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
                
                guard let commentText = commentTextField?.text else { return }
                
                self.postController.addComment(with: commentText, to: &self.post!)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

            let addAudioCommentAction = UIAlertAction(title: "Add Audio", style: .default) { (_) in

                self.performSegue(withIdentifier: "AudioCommentSegue", sender: self)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(addCommentAction)
            alert.addAction(addAudioCommentAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return (post?.comments.count ?? 0) - 1
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? ImagePostDetailTableViewCell else { return UITableViewCell() }

            cell.comment = post?.comments[indexPath.row + 1]
            cell.delegate = self
            loadAudio(for: cell, forItemAt: indexPath)

            return cell
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "AudioCommentSegue" {
                if let audioVC = segue.destination as? CreateAudioCommentViewController {
                    audioVC.delegate = self
                }
            }
        }

        func loadAudio(for imagePostAudioCell: ImagePostDetailTableViewCell, forItemAt indexPath: IndexPath) {

            let comment = post.comments[indexPath.row + 1]

            guard let audioURL = comment.audioURL else { return }
            let audioURLString = audioURL.absoluteString
            if let mediaData = cache.value(for: audioURLString) {
                imagePostAudioCell.setAudioData(data: mediaData)
                self.tableView.reloadRows(at: [indexPath], with: .none)
                return
            }

            let fetchOp = FetchAudioOperation(comment: comment, post: post)

            let cacheOp = BlockOperation {
                if let data = fetchOp.mediaData {
                    self.cache.cache(value: data, for: audioURLString)
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }

            let completionOp = BlockOperation {
                defer { self.operations.removeValue(forKey: audioURLString) }

                if let currentIndexPath = self.tableView?.indexPath(for: imagePostAudioCell),
                    currentIndexPath != indexPath {
                    print("Got audio for now-reused cell")
                    return
                }

                if let data = fetchOp.mediaData {
                    imagePostAudioCell.setAudioData(data: data)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }

            cacheOp.addDependency(fetchOp)
            completionOp.addDependency(fetchOp)

            mediaFetchQueue.addOperation(fetchOp)
            mediaFetchQueue.addOperation(cacheOp)
            OperationQueue.main.addOperation(completionOp)

            operations[audioURLString] = fetchOp
        }

        func playRecording(with audioData: Data) {
            do {
                audioPlayer = try AVAudioPlayer(data: audioData)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error Playing Audio Data")
            }
        }
        
        var post: Post!
        var postController: PostController!
        var imageData: Data?
        var audioPlayer: AVAudioPlayer?

        private var operations = [String : Operation]()
        private let mediaFetchQueue = OperationQueue()
        private let cache = Cache<String, Data>()

        @IBOutlet weak var imageView: UIImageView!
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var authorLabel: UILabel!
        @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    }

    extension ImagePostDetailTableViewController: AudioCommentViewControllerDelegate {
        func saveAudioCommentButtonWasTapped(_ audioData: Data, _ viewController: UIViewController) {
            self.postController.createAudioComment(with: audioData) { (comment) in
                if let comment = comment {
                    self.postController.addAudioComment(with: comment, to: &self.post!)
                    viewController.dismiss(animated: true, completion: nil)
                    self.tableView.reloadData()
                }
            }
        }
    }

    extension ImagePostDetailTableViewController: AVAudioPlayerDelegate {

        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            
        }

        func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
            if let error = error {
                print("Audio Player error: \(error)")
            }
        }
    }

    extension ImagePostDetailTableViewController: ImagePostDetailTableViewCellDelegate {
        func playAudioButtonWasTapped(data: Data) {
            playRecording(with: data)
        }
    }


