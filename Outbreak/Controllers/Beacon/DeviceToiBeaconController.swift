//
//  DeviceToiBeaconController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/25/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class DeviceToiBeaconController: UIViewController, CBPeripheralManagerDelegate {
    
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!

    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }

        let localBeaconUUID = "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"
        let localBeaconMajor: CLBeaconMajorValue = 123
        let localBeaconMinor: CLBeaconMinorValue = 456

        let uuid = UUID(uuidString: localBeaconUUID)!

        localBeacon = CLBeaconRegion(uuid: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "Jessie Pichardo")
        
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as? [String: Any])
            print("Advertising: ", beaconPeripheralData as Any)
            print("Keys: ", beaconPeripheralData.allKeys as Any)
            print("Values: ", beaconPeripheralData.allValues as Any)
            print("Identifier: ", localBeacon.identifier)
            
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }


}

