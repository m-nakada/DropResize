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
  
  // MARK: - NSApplicationDelegate
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    let defaults: [String: AnyObject] = [UserDefaultsKey.SelectedScaleMenuTitle:"50%"]
    NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
    NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
  }
  
  // When user drop a file to the App icon, this method is called.
  func application(theApplication: NSApplication, openFile filename: String) -> Bool {
    self.resize(path: filename)
    return true
  }
  
  func applicationWillTerminate(aNotification: NSNotification) {
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  func applicationDockMenu(sender: NSApplication) -> NSMenu? {
    let defaults = NSUserDefaults.standardUserDefaults()
    guard let selectedScaleTitle = defaults.objectForKey(UserDefaultsKey.SelectedScaleMenuTitle) as? String else { return nil }
    let menu: NSMenu = NSMenu(title: "Resize Image")
    
    // Add scale menu
    for title in scaleDict.keys.sort(>) {
      let item = NSMenuItem(title: title, action:"scaleMenuAction:", keyEquivalent: "")
      if title == selectedScaleTitle {
        item.state = NSOnState
      }
      menu.addItem(item)
    }
    
    return menu
  }
  
  // MARK: - Action
  
  @IBAction func scaleMenuAction(sender: NSMenuItem) {
    self.inputScale = self.scaleDict[sender.title]!
    NSUserDefaults.standardUserDefaults().setObject(sender.title, forKey: UserDefaultsKey.SelectedScaleMenuTitle)
    NSUserDefaults.standardUserDefaults().synchronize()
  }
  
  // MARK: - Image Function
  
  func resize(path path: String) {
    let url = NSURL(fileURLWithPath: path)
    let ir = ImageResizer(inputScale: self.inputScale, url: url)
    
    if case let (image?, fileType?) = ir.resize() {
      NSBitmapImageRep(CIImage: image)
        .representationUsingType(fileType, properties: [:])?
        .writeToURL(url, atomically: true)
      postUserNotification(url)
    } else {
      print("Could not resize image: \(url)")
    }
  }
  
  // MARK: - User Notification
  
  func postUserNotification(url: NSURL) {
    let notif = NSUserNotification()
    notif.title             = NSLocalizedString("Resized", comment: "")
    notif.informativeText   = url.lastPathComponent
    notif.soundName         = NSUserNotificationDefaultSoundName;
    notif.userInfo          = ["url":url.absoluteString]
    NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notif)
  }
  
}

// MARK: - NSUserNotificationCenterDelegate

extension AppDelegate: NSUserNotificationCenterDelegate {
  func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
    return true
  }
  
  func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
    guard let userInfo = notification.userInfo,
              path = userInfo["url"] as? String,
              url = NSURL(string: path) else { return }
    NSWorkspace.sharedWorkspace().openURL(url)
  }
}
