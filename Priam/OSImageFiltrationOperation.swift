//
//  OSImageFiltrationOperation.swift
//  OperationSample
//
//  Created by Vincent on 09/02/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class OSImageFiltrationOperation: OSBaseAsynchronousOperation {
    var rawImage:UIImage! {
        willSet {
            self.inputImage = CIImage.init(image: newValue as UIImage!)
        }
    }
    var inputImage:CIImage!
    var gaussianBluredImage:UIImage?
    var imageIndex:IndexPath!
    
    private let duration = 1.5
    private let totalFrameCount = 20
//    private var transitionStartTime = CACurrentMediaTime()

    weak var delegateImageView: UIImageView?
    var filteredImages: Array<UIImage>? = Array()
    
    lazy var context:CIContext = {
        return CIContext.init(options: nil)
    }()
    override init() {
        super.init()
//        self.task = URLSessionTask()
    }
    convenience init(index:IndexPath) {
        self.init()
        self.imageIndex = index
    }
//    @objc func timerFired(displayLink: CADisplayLink) {
//        guard let filter = blurEffect(image: rawImage) else {
//            //If the filter is nil, invalidate our display link.
//            displayLink.invalidate()
//            return
//        }
//
//        let currentTime = CACurrentMediaTime()
//        let rawProgress = (currentTime - transitionStartTime) / duration
//        let progress = min(rawProgress, 1.0)
//        filter.setValue(50-progress*50, forKey: kCIInputRadiusKey)
//        //After we set a value on our filter, the filter applies that value to the image and filters it accordingly so we get a new outputImage immediately after the setValue finishes running.
//        let resultImage = filter.value(forKey: "outputImage") as! CIImage
//        let cgImage = context.createCGImage(resultImage, from: inputImage.extent)
//
//        let blurredImage = UIImage.init(cgImage: cgImage!, scale: rawImage.scale, orientation: .up)
//
//        delegateImageView?.image = blurredImage
//
//        if progress == 1.0 {
//
//            displayLink.invalidate()
//            completeOperation()
//        }
//    }
    
    override func main () {
        if self.isCancelled {
            return
        }
        let filter = self.filterEffect(image: self.rawImage!)
        if (filter) != nil {
            
            for i in 0..<totalFrameCount-1 {
                let frameImage = drawImageOffScreen(filter: filter!, frameIndex: i)
                self.filteredImages?.append(frameImage)
            }
            self.filteredImages?.append(rawImage!)
        }
        completeOperation()
    }
    
    func filterEffect(image: UIImage) -> CIFilter!{
        let imageToBlur = CIImage(image: image)
        
//        let blurfilter = CIFilter(name: "CIRippleTransition")
        let blurfilter = CIFilter(name: "CIGaussianBlur")
//        blurfilter?.setValue(imageToBlur, forKey: "inputImage")
        blurfilter?.setValue(imageToBlur, forKey: kCIInputImageKey)
//        blurfilter?.setValue(imageToBlur, forKey: kCIInputTargetImageKey)
//        blurfilter?.setValue(CIImage(), forKey: kCIInputShadingImageKey)
        return blurfilter
        
    }
    
    func drawImageOffScreen(filter:CIFilter, frameIndex:Int) -> UIImage {
//        CGRect imageRect = CGRectMake(0.0, 0.0, kAppIconHeight, kAppIconHeight);
//        UIGraphicsBeginImageContextWithOptions(itemSize, NO, [UIScreen mainScreen].scale);
//        [image drawInRect:imageRect];
//        self.appRecord.appIcon = UIGraphicsGetImageFromCurrentImageContext();  // UIImage returned.
//        UIGraphicsEndImageContext();
        let imageRect = CGRect.init(x: 0, y: 0, width: 100, height: 150)
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: imageRect.width, height: imageRect.height), false, UIScreen.main.scale)
        let rawProgress = Double(frameIndex) / Double(totalFrameCount)
        let progress = min(rawProgress, 1.0)
        filter.setValue(50-progress*50, forKey: kCIInputRadiusKey)

        let resultImage = filter.value(forKey: "outputImage") as! CIImage
        let cgImage = context.createCGImage(resultImage, from: inputImage!.extent)
        let blurredImage = UIImage.init(cgImage: cgImage!, scale: rawImage!.scale, orientation: .up)

        blurredImage.draw(in: imageRect)
        let frameImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return frameImage!
    }
    override func completeOperation() {
        print(self.imageIndex.description," is filtered")
        super.completeOperation()
    }
    override func start() {
//        transitionStartTime = CACurrentMediaTime()
        super.start()
    }
    
}
