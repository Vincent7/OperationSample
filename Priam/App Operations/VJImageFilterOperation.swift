//
//  VJImageFilterOperation.swift
//  OperationSample
//
//  Created by Vincent on 28/03/2018.
//  Copyright © 2018 Vincent. All rights reserved.
//

import UIKit

class VJImageFilterOperation: VJBaseOperation {
    
    var context:ContextImageFilterable
    
//    let rawImage:UIImage
    var filterInputImage:CIImage?
    
//    private let duration = 1.5
    private let totalFrameCount = 20
    
    var filteredImage: UIImage = UIImage()
//    var filteredImages: Array<UIImage>? = Array()
    static let context:CIContext = CIContext.init(options: nil)
    
    func drawImageOffScreen(filter:CIFilter, frameIndex:Int) -> UIImage {
        let imageRect = CGRect.init(x: 0, y: 0, width: 100, height: 150)
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: imageRect.width, height: imageRect.height), false, UIScreen.main.scale)
        let rawProgress = Double(frameIndex) / Double(totalFrameCount)
        let progress = min(rawProgress, 1.0)
        filter.setValue(50-progress*50, forKey: kCIInputRadiusKey)
        
        let resultImage = filter.value(forKey: "outputImage") as! CIImage
        let cgImage = VJImageFilterOperation.context.createCGImage(resultImage, from: (filterInputImage?.extent)!)
        let blurredImage = UIImage.init(cgImage: cgImage!, scale: (self.context.previewRawImage?.scale)!, orientation: .up)
        
        blurredImage.draw(in: imageRect)
        let frameImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return frameImage!
    }
    func filterEffect(image: UIImage) -> CIFilter!{
        let imageToBlur = CIImage(image: image)
        
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter?.setValue(imageToBlur, forKey: kCIInputImageKey)
        return blurfilter
        
    }
    
    init(context:inout ContextImageFilterable, completion : (() -> ())?) {
        self.context = context
        super.init()
        self.completionBlock = completion
    }
    
    override func execute() {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            let strongSelf:VJImageFilterOperation! = self
            guard let image:UIImage = strongSelf.context.previewRawImage else{
                strongSelf.finish()
                return 
            }
            strongSelf.filterInputImage = CIImage.init(image: image)!
            let filter = strongSelf.filterEffect(image: image)
            assert(filter != nil, "Cannot create filter.")
            //            for i in 0..<strongSelf.totalFrameCount-1 {
            //                let frameImage = strongSelf.drawImageOffScreen(filter: filter!, frameIndex: i)
            //                strongSelf.filteredImages?.append(frameImage)
            //            }
            let frameImage = strongSelf.drawImageOffScreen(filter: filter!, frameIndex: 5)
            strongSelf.filteredImage = frameImage
            
            //            strongSelf.filteredImages?.append(strongSelf.context.previewRawImage!)
            strongSelf.context.animFilterdImage = strongSelf.filteredImage
            strongSelf.finish()
        }
        
        
    }
    override func finished(errors: [Error]) {
        self.completionBlock!()
    }
}
