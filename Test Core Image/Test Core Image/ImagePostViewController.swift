//
//  ImagePostViewController.swift
//  Test Core Image
//
//  Created by Kelson Hartle on 6/29/20.
//  Copyright © 2020 Kelson Hartle. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {
    private let context = CIContext(options: nil)
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
            updateViews()
        }
    }
    
    //CI False color
    private let ciFalseColorFilter = CIFilter.falseColor()
    private let ciPhotoEffectTonal = CIFilter.photoEffectTonal()
    var colorOne: CIColor = .clear
    var colorTwo: CIColor = .clear
    
    //CIZoomBlur
    var ciZoomBlurCGPoint: CGPoint = CGPoint(x: 50, y: 150)
    
    @IBOutlet weak var falseColorSegmentedControlOne: UISegmentedControl!
    @IBOutlet weak var falseColorSegmentedControlTwo: UISegmentedControl!
    @IBOutlet weak var ciBoxBlurSlider: UISlider!
    @IBOutlet weak var ciZoomBlurSegmentedControl: UISegmentedControl!
    @IBOutlet weak var ciZoomBlurSliderInputAmount: UISlider!
    @IBOutlet weak var ciSepiaToneSLider: UISlider!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // FalseColorFilter
        falseColorSegmentedControlOne.addTarget(self, action: #selector(didChangeColorIndexOne(_:)), for: .valueChanged)
        falseColorSegmentedControlTwo.addTarget(self, action: #selector(didChangeColorIndexTwo(_:)), for: .valueChanged)
        ciFalseColorFilter.color0 = .clear
        ciFalseColorFilter.color1 = .clear
        print(ciFalseColorFilter.attributes)
        //
        
        //CIZOOMBLUR
        ciZoomBlurSegmentedControl.addTarget(self, action: #selector(didChangeInputCenterPoint(_:)), for: .valueChanged)
        
        originalImage = imageView.image
        
    }
    
    // 414*3 = 1.242 pixels (portrait on iPhone 11 Pro Max)
    private func filterImage(_ image: UIImage) -> UIImage? {
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // Filtering
        // May not work for some custom filters.  (May need to use KVC (key value coding protocol))
        
        // FalseColorFilter
        ciFalseColorFilter.inputImage = ciImage
        ciFalseColorFilter.color0 = colorOne
        ciFalseColorFilter.color1 = colorTwo
        
        //CIImage -> CGImage -> UIImage
        guard let outputFalseColorFilterCIImage = ciFalseColorFilter.outputImage else { return nil }
        guard let falseColorFilterOutputImage = context.createCGImage(outputFalseColorFilterCIImage, from: CGRect(origin: .zero, size: image.size)) else { return nil }
        
        // MARK: - FilterEffectTonal
        ciPhotoEffectTonal.inputImage = ciImage
        
        //CIImage -> CGImage -> UIImage
        guard let outputPhotoEffectTonal = ciPhotoEffectTonal.outputImage else { return nil }
        //
        
        // MARK: - GaussianBlur
        let gaussianBlur = CIFilter.gaussianBlur()
        gaussianBlur.inputImage = outputPhotoEffectTonal
        gaussianBlur.radius = ciBoxBlurSlider.value
        guard let gaussianBlurOutputsImage = gaussianBlur.outputImage else { return nil }
        
        
        guard let outputCGImage = context.createCGImage(gaussianBlurOutputsImage, from: CGRect(origin: .zero, size: image.size)) else {return image}
        
        // MARK: - CiPhotoEffectInstant
        let photoEffectInstant = CIFilter.photoEffectInstant()
        photoEffectInstant.inputImage = outputPhotoEffectTonal
        guard let photoEffectIntantOutputImage = photoEffectInstant.outputImage else { return image }
        guard let outputPhotoEffectInstantCGImage = context.createCGImage(photoEffectIntantOutputImage, from: CGRect(origin: .zero, size: image.size)) else {return image}
        

        // MARK: - ciZoom Blur
        let zoomBlur = CIFilter.zoomBlur()
        zoomBlur.inputImage = outputPhotoEffectTonal
        
        zoomBlur.center = ciZoomBlurCGPoint
        zoomBlur.amount = ciZoomBlurSliderInputAmount.value
        
        guard let ciZoomBlurOutputCIImage = zoomBlur.outputImage else { return image }
        guard let outPutCGCiZoomBlurImage = context.createCGImage(ciZoomBlurOutputCIImage, from: CGRect(origin: .zero, size: image.size)) else {return image}
        
        // MARK: -  CI Sepia Tone
        let sepiaTone = CIFilter.sepiaTone()
        sepiaTone.inputImage = photoEffectIntantOutputImage
        sepiaTone.intensity = ciSepiaToneSLider.value
        guard let sepiaToneOutPutCIImage = sepiaTone.outputImage else { return image }
         guard let outPutCGCiSepiaToneImage = context.createCGImage(sepiaToneOutPutCIImage, from: CGRect(origin: .zero, size: image.size)) else {return image}
        
        
        return UIImage(cgImage: outPutCGCiSepiaToneImage)
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
    
    @IBAction func didChangeCiZoomBlur(_ sender: Any) {
        updateViews()
    }
    //
    
    @IBAction func didChangeSepiaToneIntensity(_ sender: Any) {
        updateViews()
    }
    
    
    
    //MARK: - OBJC functions for (CI ZOOM BLUR)
    @objc private func didChangeInputCenterPoint(_ sender: UISegmentedControl) {
        ciZoomBlurCGPoint = determineZoomBlur()
        updateViews()
    }
    
    //MARK: - OBJC functions for (CI FALSE COLOR)
    @objc private func didChangeColorIndexOne(_ sender: UISegmentedControl) {
        colorOne = determineColorOne()
        updateViews()
    }
    
    @objc private func didChangeColorIndexTwo(_ sender: UISegmentedControl) {
        colorTwo = determineColorTwo()
        updateViews()
    }
    
    
    @IBAction func ciBoxBlurSliderMoved(_ sender: UISlider) {
        updateViews()
    }
    
    //MARK: - Helper functions for (CI FALSE COLOR)
    
    private func determineColorOne() -> CIColor {
        // could use a guard let here later if necessary
        
        switch falseColorSegmentedControlOne.selectedSegmentIndex {
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
        
        print("--CHANGE-- \(colorOne)")
        return colorOne
    }
    
    private func determineColorTwo() -> CIColor {
        switch falseColorSegmentedControlTwo.selectedSegmentIndex {
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
        print("--CHANGE-- \(colorTwo)")
        return colorTwo
    }
    
    private func updateViews() {
        guard let scaledImage = scaledImage else { return }
        //Use if else statements, in order to change the view (update) depending on which button is tapped.
        
        imageView.image = filterImage(scaledImage)
    }
    
    @IBAction func choosePhotoButtonTapped(_ sender: Any) {
        presentImagePickerController()
    }
    
    
    //MARK: - Image picker controller helper
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Photo Library error.")
            return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
}
extension ImagePostViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        dismiss(animated: true) {
            DispatchQueue.main.async {
                self.colorOne = .clear
                self.colorTwo = .clear
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ImagePostViewController : UINavigationControllerDelegate {
    
    
}
