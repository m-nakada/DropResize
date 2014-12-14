//
//  ImageResizer.swift
//  DropResize
//
//  Created by mitsuru on 12/13/14.
//  Copyright (c) 2014 mna. All rights reserved.
//

import Cocoa

class ImageResizer: NSObject {
  var inputScale: Float = 0.5
  var inputAspectRatio: Float = 1.0
  
  init(inputScale: Float, inputAspectRatio: Float) {
    super.init()
    self.inputScale = inputScale
    self.inputAspectRatio = inputAspectRatio
  }
  
  func resize(url: NSURL) -> CIImage? {
    let image: CIImage = CIImage(contentsOfURL: url)
    
    // Create resize filter
    let filter = CIFilter(name: "CILanczosScaleTransform")
    filter.setValue(image, forKey: "inputImage")
    filter.setValue(self.inputScale, forKey: "inputScale")
    filter.setValue(self.inputAspectRatio, forKey: "inputAspectRatio")
    
    // Get output image
    let outputImage = filter.valueForKey("outputImage") as CIImage
    return outputImage
  }
}
