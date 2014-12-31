//
//  BLEService.swift
//  KardiaApp
//
//  Created by Charlie Depman on 12/29/14.
//  Copyright (c) 2014 Kardia. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BLEServiceUUID = CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")
let EKGCharUUID = CBUUID(string: "713D0002-503E-4C75-BA94-3148F18D941E")
let RXUUID = CBUUID(string: "713D0003-503E-4C75-BA94-3148F18D941E")
let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"
let GotBLEDataNotification = "GotBLEData"

class BTService: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    var positionCharacteristic: CBCharacteristic?
    var RXCharacteristic: CBCharacteristic?
    var dataPoints: [String] = []
    
    init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
    
    deinit {
        self.reset()
    }
    
    func startDiscoveringServices() {
        self.peripheral?.discoverServices([BLEServiceUUID])
    }
    
    func reset() {
        if peripheral != nil {
            peripheral = nil
        }
        
        // Deallocating therefore send notification
        self.sendBTServiceNotificationWithIsBluetoothConnected(false)
    }
    
    // Mark: - CBPeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        let uuidsForBTService: [CBUUID] = [EKGCharUUID, RXUUID]
        
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        if ((peripheral.services == nil) || (peripheral.services.count == 0)) {
            // No Services
            return
        }
        
        for service in peripheral.services {
            if service.UUID == BLEServiceUUID {
                peripheral.discoverCharacteristics(uuidsForBTService, forService: service as CBService)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            return
        }
        
        if (error != nil) {
            return
        }
        
        for characteristic in service.characteristics {
            //        println(characteristic)
            if characteristic.UUID == EKGCharUUID {
                self.positionCharacteristic = (characteristic as CBCharacteristic)
                peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
                // Send notification that Bluetooth is connected and all required characteristics are discovered
                self.sendBTServiceNotificationWithIsBluetoothConnected(true)
            }
            if characteristic.UUID == RXUUID {
                self.RXCharacteristic = (characteristic as CBCharacteristic)
                
            }
            
        }
    }
    
    // This function executes when the BLE device updates the value it is transmitting.
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if self.positionCharacteristic == nil {
            return
        }
        // Get the raw data from the device and type cast it to string.
        var charRawValue: NSData = self.positionCharacteristic!.value
        var charValue: String = NSString(data: charRawValue, encoding: NSUTF8StringEncoding)!
        
        // Store the latest datapoints in an array to be passed on for visualization
        dataPoints.append(charValue)
        if dataPoints.count > 15 {
            dataPoints.removeAtIndex(0)
        }
        // Pass the datapoints on via a notification.
        let passData = ["passData": dataPoints]
        NSNotificationCenter.defaultCenter().postNotificationName(GotBLEDataNotification, object: self, userInfo: passData)
    }
    
    
    func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
        let connectionDetails = ["isConnected": isBluetoothConnected]
        NSNotificationCenter.defaultCenter().postNotificationName(BLEServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
    }
    
}
