//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Kelson Hartle on 7/6/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    private var player: AVPlayer!
    var postController = PostController()
    var post: Post?
    var videoData: Data?
    private var fileURL: URL?
    
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        
        setUpcaptureSession()
        
        // good place to add tap gestures
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
               view.addGestureRecognizer(tapGesture)
        
        let leaveKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard(_:)))
        view.addGestureRecognizer(leaveKeyboardGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
           print("ok")
                    // TODO: Can send to fire base from here
                    guard let title = titleTextField.text, title != "", let url = fileURL, let vidData = try? Data(contentsOf: url) else { return }
        
        
    }

    @objc private func dissmissKeyboard(_ tapGesture: UITapGestureRecognizer) {
        view.endEditing(true)
        
    }
    
    @objc private func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        // with more complex situations you will need to use a switch statment or control flow statement. (switch.state)
        print("tap")
        
        switch tapGesture.state {
        case .ended:
            // replay the movie
            replayMovie()
        default:
            break //ignore all other states.
        }
    }
    
    private func replayMovie() {
        guard let player = player else { return }
        // 30 FPS, 60 FPS, 24 FPS
        // CM time represents the actual video frames (0,30) = first frame
        // CMTIME(1,30) = second frame
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    private func setUpcaptureSession() {
        
        captureSession.beginConfiguration()
        // add inputs //
        let camera = bestCamera()
        //video
        guard let captureInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(captureInput) else {
                fatalError("Can't create the input from the camera.")
        }
        captureSession.addInput(captureInput)
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            // FURTURE: Play with 4k
            captureSession.sessionPreset = .hd1920x1080
        }
        
        //audio
        let microhone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microhone),
            captureSession.canAddInput(audioInput) else { fatalError("Cant create microphone input.")}
        
        captureSession.addInput(audioInput)
        
        
        // add outputs //
        //recording to disk
        guard captureSession.canAddOutput(fileOutput) else { fatalError("cannot record to disk.")}
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        
        //live preview
        cameraView.session = captureSession
        
    }
    
    private func bestCamera() -> AVCaptureDevice {
        // all iphones have  awide angle camera ( front and back )
        if let ultraWideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        
        if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideCamera
        }
        // Could also add a button for the developer to toggle the cameras
        
        fatalError("No cameras on the device (or your running on the simulator)")
        
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No Audio")
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
        
    }
    //TODO : Recreate this method tomorrow in order to
    /// Creates a new file URL in the documents directory
       private func newRecordingURL() -> URL {
           let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           
           let formatter = ISO8601DateFormatter()
           formatter.formatOptions = [.withInternetDateTime]
           
           let name = formatter.string(from: Date())
           let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
           return fileURL
       }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        // top left corner (can also do Fullscreen, you'd need a close button)
        var topRectangle = view.bounds
        topRectangle.size.height = topRectangle.size.height / 4
        topRectangle.size.width = topRectangle.size.width / 3 // create a constant for a "magic number"
        topRectangle.origin.y = view.layoutMargins.top
        playerLayer.frame = topRectangle
        
        view.layer.addSublayer(playerLayer) // adding a sublayer ( similar to adding a view but at a lower level in the framework )
        
        player.play()
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        print("didFinishRecording")
        
        if let error = error {
            print("Video Recording Error: \(error)")
        } else {
            fileURL = outputFileURL
            playMovie(url: outputFileURL)
            
        }
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        //Update UI
        print("didStartRecording \(fileURL)")
        
        updateViews()
    }
}
