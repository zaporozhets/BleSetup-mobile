//
//  GattController.swift
//  BleSetup
//
//  Created by Taras Zaporozhets on 5/30/17.
//  Copyright © 2017 Taras Zaporozhets. All rights reserved.
//

import UIKit
import CoreBluetooth

class BleController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    
    let BLE_NAME = "Test device"
    let BLE_SERVICE_UUID: String = "00001234-0000-1000-8000-00805F9B34FB"
    let BLE_CHARACTERISTIC_UUID: String = "00001234-0000-1000-8000-00805F9B34FB"
    
    var rxCharacteristic: CBCharacteristic!
    var txCharacteristic: CBCharacteristic!
    
    func initialize() {
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func disconnect() {
        manager.cancelPeripheralConnection(peripheral)
    }
    
    func writeData(dataToSend: String) {
        let start_byte : [UInt8] = [0xFF];
        let stop_byte : [UInt8] = [0x00];
        
        let bytes : [UInt8] = start_byte + Array(dataToSend.utf8) + stop_byte
        let data = Data(bytes:bytes)
        peripheral.writeValue(data, for: rxCharacteristic,type: CBCharacteristicWriteType.withResponse)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("Start scanning...")
            central.scanForPeripherals( withServices: nil, options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
            .object( forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        if device?.contains(BLE_NAME) == true {
            print("Found device...")
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to " +  peripheral.name!)
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.uuid.uuidString == BLE_SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid.uuidString == BLE_CHARACTERISTIC_UUID {
                self.peripheral.setNotifyValue(true, for: thisCharacteristic)
                rxCharacteristic = thisCharacteristic;
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (characteristic.uuid.uuidString == "2A00") {
            //value for device name recieved
            let deviceName = characteristic.value
            print(deviceName ?? "No Device Name")
        } else if (characteristic.uuid.uuidString == "2A29") {
            //value for manufacturer name recieved
            let manufacturerName = characteristic.value
            print(manufacturerName ?? "No Manufacturer Name")
        } else if (characteristic.uuid.uuidString == "2A23") {
            //value for system ID recieved
            let systemID = characteristic.value
            print(systemID ?? "No System ID")
        } else if (characteristic.uuid.uuidString == BLE_CHARACTERISTIC_UUID) {
            //data recieved
            if(characteristic.value != nil) {
                
                let start_byte: UInt8 = 0xFF;
                let stop_byte: UInt8 = 0x00;
                
                var rxData = Data()
                for index in 0...characteristic.value!.count{
                    
                    let byte = characteristic.value![index]
                    
                    switch byte {
                    case start_byte:
                        rxData = Data()
                    case stop_byte:
                        let rxString = String(data: rxData, encoding: String.Encoding.utf8) ?? "Omg"
                        print(rxString)
                    default:
                        rxData.append(byte)
                    }
                }
            }
        }
    }
}


