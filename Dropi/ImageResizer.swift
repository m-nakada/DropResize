//
//  ImageResizer.swift
//  Dropi
//
//  Created by m-nakada on 12/13/14.
//  Copyright (c) 2014 mna. All rights reserved.
//

import Cocoa

struct ImageResizer {
  var inputScale: Float
  var inputAspectRatio: Float
  var url: NSURL
  var fileType: NSBitmapImageFileType? {
    guard let pathExtension = url.pathExtension else { return nil }
    switch (pathExtension.lowercaseString) {
    case "png":
      return .NSPNGFileType
    case "jpg", "jpeg":
      return .NSJPEGFileType
    case "tif", "tiff":
      return .NSTIFFFileType
    default:
      return .NSPNGFileType
    }
  }
  
  init(inputScale: Float = 0.5, inputAspectRatio: Float = 1.0, url: NSURL) {
    self.inputScale = inputScale
    self.inputAspectRatio = inputAspectRatio
    self.url = url
  }
  
  func resize() -> (CIImage?, NSBitmapImageFileType?)  {
    guard let image = CIImage(contentsOfURL: url) else { return (nil, nil) }
    
    // Create resize filter
    guard let filter = CIFilter(name: "CILanczosScaleTransform") else { return (nil, nil) }
    filter.setValue(image, forKey: "inputImage")
    filter.setValue(self.inputScale, forKey: "inputScale")
    filter.setValue(self.inputAspectRatio, forKey: "inputAspectRatio")
    
    // Get output image
    guard let outputImage = filter.valueForKey("outputImage") as? CIImage else { return (nil, nil) }
    guard let fileType = fileType else { return (outputImage, nil) }
    return (outputImage, fileType)
  }
  
}
