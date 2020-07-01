//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

enum FilterType {
    case ciFalseColor
    case ciEffectTonal
    case ciEffectInstant
    case ciSepiaTone
    case ciZoomBlur
    
}

class ImagePostViewController: ShiftableViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var ciZoomBlurSlider: UISlider!
    @IBOutlet weak var ciZoomBlurSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var falseColorOneSegmentedControl: UISegmentedControl!
    @IBOutlet weak var falseColorTwoSegmentedControl: UISegmentedControl!
    
    
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    var context = CIContext(options: nil)
    var filterSelected: FilterType!
    
    //PROPERTIES CI FALSE COLOR
    var colorOne: CIColor = .clear
    var colorTwo: CIColor = .clear
    
    var ciZoomBlurCGPoint: CGPoint = CGPoint(x: 50, y: 150)
    
    
    private var originalImage: UIImage? {
        didSet {
            // 414*3 = 1.242 pixels (portrait on iPhone 11 Pro Max)
            guard let originalImage = originalImage else {
                scaledImage = nil // clear out the image if it is nil
                return
            }
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale //will let us know if it is a 1x 2x 3x
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    private var scaledImage: UIImage? {
        didSet {
            updateImage()
            saveButton.isHidden = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageViewHeight(with: 1.0)
        updateViews()
        
        falseColorOneSegmentedControl.addTarget(self, action: #selector(didChangeColorIndexOne(_:)), for: .valueChanged)
        falseColorTwoSegmentedControl.addTarget(self, action: #selector(didChangeColorIndexTwo(_:)), for: .valueChanged)
        
        ciZoomBlurSegmentedControl.addTarget(self, action: #selector(didChangeInputCenterPoint(_:)), for: .valueChanged)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide all buttons until needed
        
        saveButton.isHidden = false

        falseColorOneSegmentedControl.isHidden = true
        falseColorTwoSegmentedControl.isHidden = true
        ciZoomBlurSlider.isHidden = true
        ciZoomBlurSegmentedControl.isHidden = true
        
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }
    
    private func updateImage() {
        if let scaledImage = scaledImage {
            switch self.filterSelected {
                case .ciZoomBlur:
                imageView.image = filterPhoto(scaledImage, filterSelected: .ciZoomBlur)
            case .ciFalseColor:
                imageView.image = filterPhoto(scaledImage, filterSelected: .ciFalseColor)
            case .ciEffectTonal:
                imageView.image = filterPhoto(scaledImage, filterSelected: .ciEffectTonal)
            case .ciEffectInstant:
                imageView.image = filterPhoto(scaledImage, filterSelected: .ciEffectInstant)
            case .ciSepiaTone:
                imageView.image = filterPhoto(scaledImage, filterSelected: .ciSepiaTone)
            case .none:
                break
            }
            
        } else {
            imageView.image = nil
        }
    }
    
    func filterPhoto(_ image: UIImage, filterSelected: FilterType) -> UIImage? {
        switch filterSelected {
        case .ciFalseColor:
            guard let cgImage = image.cgImage else { return nil }
            
            let ciImage = CIImage(cgImage: cgImage)
            
            let ciFalseColor = CIFilter.falseColor()
            
            ciFalseColor.inputImage = ciImage
            ciFalseColor.color0 = colorOne
            ciFalseColor.color1 = colorTwo
            
            guard let outputFalseColorFilterCIImage = ciFalseColor.outputImage else { return nil }
            guard let falseColorFilterOutputImage = context.createCGImage(outputFalseColorFilterCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }

            
            return UIImage(cgImage: falseColorFilterOutputImage)
            
        case .ciEffectTonal:
            guard let cgImage = image.cgImage else { return nil }

            let ciImage = CIImage(cgImage: cgImage)

            let ciEffectTonal = CIFilter.photoEffectTonal()
            ciEffectTonal.inputImage = ciImage
            guard let outputPhotoEffectTonal = ciEffectTonal.outputImage else { return nil }
            
            guard let outPutTonalCGImage = context.createCGImage(outputPhotoEffectTonal, from: CGRect(origin: .zero, size: image.size)) else { return image }
            
            return UIImage(cgImage: outPutTonalCGImage)
            
            
            
        case .ciZoomBlur:
            guard let cgImage = image.cgImage else { return nil }
            
            let ciImage = CIImage(cgImage: cgImage)
            
            let zoomBlur = CIFilter.zoomBlur()
            zoomBlur.inputImage = ciImage
            zoomBlur.center = ciZoomBlurCGPoint
            zoomBlur.amount = ciZoomBlurSlider.value
            
            guard let outputZoomBlur = zoomBlur.outputImage else { return nil }
            guard let outPutCGZoomBlurImage = context.createCGImage(outputZoomBlur, from: CGRect(origin: .zero, size: image.size)) else {return image}
            
            
            return UIImage(cgImage: outPutCGZoomBlurImage)
            
        case .ciEffectTonal:
            return nil
        case .ciEffectInstant:
            return nil
        case .ciSepiaTone:
            return nil
        }
        
    }
    
    //MARK: - OBJC functions for (CI FALSE COLOR)
    @objc private func didChangeColorIndexOne(_ sender: UISegmentedControl) {
        colorOne = determineColorOne()
        updateImage()
    }
    
    @objc private func didChangeColorIndexTwo(_ sender: UISegmentedControl) {
        colorTwo = determineColorTwo()
        updateImage()
    }
    
    //HELPER FUNCTIONS
    private func determineColorOne() -> CIColor {
        // could use a guard let here later if necessary
        
        switch falseColorOneSegmentedControl.selectedSegmentIndex {
        case 0:
            colorOne = .green
        case 1:
            colorOne = .blue
        case 2:
            colorOne = .red
        case 3:
            colorOne = .magenta
        default:
            fatalError()
        }
        
        return colorOne
    }
    
    private func determineColorTwo() -> CIColor {
        switch falseColorTwoSegmentedControl.selectedSegmentIndex {
        case 0:
            colorTwo = .cyan
        case 1:
            colorTwo = .gray
        case 2:
            colorTwo = .black
        case 3:
            colorTwo = .yellow
        default:
            fatalError()
        }
        return colorTwo
    }
    
    
    
    //MARK: - END (CI FALSE COLOR)
    
    //MARK: - OBJC functions for (CI ZOOM BLUR)
    @objc private func didChangeInputCenterPoint(_ sender: UISegmentedControl) {
        ciZoomBlurCGPoint = determineZoomBlur()
        updateImage()
    }
    @IBAction func didChangeZoomBlur(_ sender: Any) {
        updateImage()
    }
    
    private func determineZoomBlur() -> CGPoint {
        switch ciZoomBlurSegmentedControl.selectedSegmentIndex {
        case 0:
            ciZoomBlurCGPoint = CGPoint(x: 10, y: 20)
        case 1:
            ciZoomBlurCGPoint = CGPoint(x: 50, y: 30)
        case 2:
            ciZoomBlurCGPoint = CGPoint(x: 120, y: 50)
        case 3:
            ciZoomBlurCGPoint = CGPoint(x: 60, y: 80)
        case 4:
            ciZoomBlurCGPoint = CGPoint(x: 200, y: 300)
        default:
            fatalError()
        }
        return ciZoomBlurCGPoint
    }
    
    //MARK: - END (CI ZOOM BLUR)
    
    
    
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        @unknown default:
            print("FatalError")
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    
    
    @IBAction func falseColorTapped(_ sender: Any) {
        originalImage = imageView.image
        filterSelected = .ciFalseColor
        
        falseColorOneSegmentedControl.isHidden = false
        falseColorTwoSegmentedControl.isHidden = false
    }
    
    @IBAction func tonalTapped(_ sender: Any) {
        originalImage = imageView.image
        filterSelected = .ciEffectTonal
    }
    
    @IBAction func instantTapped(_ sender: Any) {
        originalImage = imageView.image
        filterSelected = .ciEffectInstant
    }
    
    @IBAction func sepiaTapped(_ sender: Any) {
        originalImage = imageView.image
        filterSelected = .ciSepiaTone
        
    }
    
    @IBAction func zoomBlurTapped(_ sender: Any) {
        originalImage = imageView.image
        filterSelected = .ciZoomBlur
        
        ciZoomBlurSlider.isHidden = false
        ciZoomBlurSegmentedControl.isHidden = false
        
    }
    
    
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
