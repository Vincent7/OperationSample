//
//  UIImage+AverageColor.swift
//  Priam
//
//  Created by Vincent on 2018/4/19.
//  Copyright © 2018 Vincent. All rights reserved.
//

import Foundation

extension UIImage{
    func inverseColor() -> UIColor {
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        if #available(iOS 9.0, *) {
            // Get average color.
            let context = CIContext()
            let inputImage:CIImage = CoreImage.CIImage(cgImage: self.cgImage!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            
            // Render to bitmap.
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        }
        
        // Compute result.
        let result = UIColor(red: (255.0 - CGFloat(bitmap[0])) / 255.0, green: (255.0 - CGFloat(bitmap[1])) / 255.0, blue: (255.0 - CGFloat(bitmap[2])) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }
}
