//
//  AppDelegate.swift
//  Dropi
//
//  Created by m-nakada on 12/13/14.
//  Copyright (c) 2014-2015 mna. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!
  var inputScale: Float = 0.5
  let scaleDict: [String:Float] = ["80%":0.8, "70%":0.7, "60%":0.6, "50%":0.5, "40%":0.4]
  var willOpenFilePath = String()
  
  // MARK: NSApplicationDelegate
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    // Insert code here to initialize your application
    let defaults: NSDictionary = [Constants.UserDefaultsKey.SelectedScaleMenuTitle:"50%",
                                  Constants.UserDefaultsKey.Overwrite:(false)]
    NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
  }
  
  // When user drop a file to App icon, this method is called.
  func application(theApplication: NSApplication, openFile filename: String) -> Bool {
    self.resize(filename)
    return true
  }
  
  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  func applicationDockMenu(sender: NSApplication) -> NSMenu? {
    let selectedScaleTitle = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaultsKey.SelectedScaleMenuTitle) as String
    let menu: NSMenu = NSMenu(title: "Resize Image")
    
    // Add scale menu
    let sortedKeys = Array(self.scaleDict.keys).sorted(>)
    for title in sortedKeys {
      let item = NSMenuItem(title: title, action:"scaleMenuAction:", keyEquivalent: "")
      if title == selectedScaleTitle {
        item.state = NSOnState
      }
      
      menu.addItem(item)
    }
    
    // Add separator
    menu.addItem(NSMenuItem.separatorItem())
    
    // Add settings menu
    let overwriteMenuItem = NSMenuItem(title: Constants.DockMenu.Overwrite, action: "settingsMenuAction:", keyEquivalent: "")
    overwriteMenuItem.state = NSUserDefaults.standardUserDefaults().boolForKey(Constants.UserDefaultsKey.Overwrite) ? NSOnState : NSOffState
    menu.addItem(overwriteMenuItem)
    
    return menu
  }
  
  // MARK: Image Function
  
  func toURL(path: NSString) -> NSURL {
    var toName = ""
    if NSUserDefaults.standardUserDefaults().boolForKey(Constants.UserDefaultsKey.Overwrite) {
      toName = path.lastPathComponent
    }
    else {
      let name = path.lastPathComponent.stringByDeletingPathExtension
      let ext = path.pathExtension
      toName = "\(name)_org_.\(ext)"
    }
    
    let toPath = path.stringByDeletingLastPathComponent.stringByAppendingPathComponent(toName)
    return NSURL(fileURLWithPath: toPath)!
  }
  
  func imageStorageType(path: NSString) -> NSBitmapImageFileType {
    switch (path.pathExtension.lowercaseString) {
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
  
  func copyToTemp(url: NSURL!) -> NSURL? {
    let fm = NSFileManager.defaultManager()
    if !fm.createDirectoryAtPath(Constants.Path.Temp, withIntermediateDirectories: false, attributes: nil, error: nil) {
      return nil
    }
    
    let filename = url.lastPathComponent
    let path = Constants.Path.Temp.stringByAppendingPathComponent(filename!)
    if let toURL = NSURL.fileURLWithPath(path) {
      var error: NSErrorPointer = nil
      if !fm.copyItemAtURL(url, toURL: toURL, error: error) {
        println(error)
      }
      return toURL
    }
    
    return nil
  }
  
  func resize(path: String) {
    let orgURL = NSURL(fileURLWithPath: path)!
    let toURL = self.toURL(path)
    let ir = ImageResizer(inputScale: self.inputScale, inputAspectRatio: 1.0)
    
    if let tempURL = copyToTemp(orgURL) {
      if let image = ir.resize(tempURL) {
        let bitmap = NSBitmapImageRep(CIImage: image)
        let fm = NSFileManager.defaultManager()
        
        var error: NSErrorPointer = nil
        if !fm.moveItemAtURL(orgURL, toURL: toURL, error: error) {
          fm.removeItemAtURL(tempURL, error: nil)
          return
        }
        
        bitmap
          .representationUsingType(self.imageStorageType(path), properties: [:])?
          .writeToURL(orgURL, atomically: true)
        
        fm.removeItemAtURL(tempURL, error: nil)
      }
    }
  }
  
  // MARK: Action
  
  @IBAction func scaleMenuAction(sender: AnyObject) {
    let menu = sender as NSMenuItem
    self.inputScale = self.scaleDict[menu.title]!
    
    NSUserDefaults.standardUserDefaults().setObject(menu.title, forKey: Constants.UserDefaultsKey.SelectedScaleMenuTitle)
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  @IBAction func settingsMenuAction(sender: AnyObject) {
    let menu = sender as NSMenuItem
    
    switch (menu.title) {
      case Constants.DockMenu.Overwrite:
        var flag = NSUserDefaults.standardUserDefaults().boolForKey(Constants.UserDefaultsKey.Overwrite)
        NSUserDefaults.standardUserDefaults().setBool(!flag, forKey: Constants.UserDefaultsKey.Overwrite)
      default:
       break // do nothing
    }
    
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
}
