//
//  BroadcastController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/25/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import Foundation
import UIKit

class BroadcastController: UIViewController {
    
    var iBeacon = DeviceToiBeaconController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        
        iBeacon.initLocalBeacon()
        
    }
}
