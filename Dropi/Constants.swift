//
//  Constants.swift
//  Dropi
//
//  Created by m-nakada on 12/14/14.
//  Copyright (c) 2014 mna. All rights reserved.
//

// cf.
// http://stackoverflow.com/questions/26252233/global-constants-file-in-swift

import Foundation

struct Constants {
  // You can use Constants.Path.Documents
  struct Path {
    static let Documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    static let Temp = NSTemporaryDirectory()
  }

  struct UserDefaultsKey {
    static let SelectedScaleMenuTitle = "SelectedScaleMenuTitle"
    static let Overwrite = "Overwrite" //
  }
  
  struct NotificationKey {
    static let Welcome = "kWelcomeNotif"
  }
  
  struct DockMenu {
    static let Overwrite = "Save to the same file"
  }
}
