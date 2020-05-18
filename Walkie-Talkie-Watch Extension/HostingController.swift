//
//  HostingController.swift
//  Walkie-Talkie-Watch Extension
//
//  Created by Hower Chen on 2020/5/6.
//  Copyright © 2020 Hower Chen. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<Main> {
    override var body: Main {
        return Main()
    }
}
