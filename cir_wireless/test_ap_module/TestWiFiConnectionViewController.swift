//
//  TestWiFiConnectionViewController.swift
//  cir_wireless
//
//  Created by softel on 30/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth

class TestWiFiConnectionViewController: UIViewController {
    
    var bluetoothActions                : CoreBluetoothActions?
    var cirWireless                     : CirWirelessModel?
    
    var machineState                    : TestConnectionMachineState = ._POLING
    
    
    // MARK: Servicios bluetooth de la cir wireless
    var cwProtocolService                       : CBService?
     
     
    // MARK: Caracteristicas bluetooth de la cir wireless
    var cwProtocolNotificationCharac            : CBCharacteristic?
    var cwProtocolWriteCharacteristic           : CBCharacteristic?
    
    // Outlets
    @IBOutlet weak var iPLabel          : UILabel!
    @IBOutlet weak var ssidLabel        : UILabel!
    @IBOutlet weak var rssiLabel        : UILabel!
    @IBOutlet weak var aPLabel          : UILabel!
    @IBOutlet weak var internetLabel    : UILabel!
    @IBOutlet weak var dataLabel        : UILabel!
    @IBOutlet weak var statusLabel      : UILabel!
    @IBOutlet weak var cwMacLabel       : UILabel!
    
    
    // Ciclo de vida de la vista --------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let _ = bluetoothActions {
            bluetoothActions?.bluetoothBaseDelegate  = self
            bluetoothActions?.bluetoothPolingDelegate   = self
            bluetoothActions?.setCirWirelessNotifyCharacteristic(enable: true, notifyCharacteristic: cwProtocolNotificationCharac!)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        bluetoothActions?.setCirWirelessNotifyCharacteristic(enable: false, notifyCharacteristic: cwProtocolNotificationCharac!)
    }
    // -----------------------------------------------------------
    
    
    func validateMachineState (protocolResponse: CirProtocolResponse) {
        switch machineState {
        case ._POLING:
            print("POLING")
            
        case ._WIFI_CONFIGURING:
            print("_WIFI_CONFIGURING")
        case ._WIFI_NOT_CONNECTED:
            print("_WIFI_NOT_CONNECTED")
        case ._WIFI_SSID_FAILED:
            print("_WIFI_SSID_FAILED")
        case ._WIFI_CONNECTING:
            print("_WIFI_CONNECTING")
        case ._WIFI_CONNECTED:
            print("_WIFI_CONNECTED")
        case ._WIFI_IP_FAILED:
            print("_WIFI_IP_FAILED")
        case ._WIFI_GET_LOCATION:
            print("_WIFI_GET_LOCATION")
        case ._WIFI_INTERNET_READY:
            print("_WIFI_INTERNET_READY")
        case ._WIFI_TRANSMITING:
            print("_WIFI_TRANSMITING")
        }
    }
    
}


extension TestWiFiConnectionViewController: BluetoothBaseProtocol {
    func updateCentralState(newState: CBManagerState) {
        print("updateCentralState: ")
    }
    
    func updateBluetoothActionProcess(status: BluetoothActionsProcess) {
        print("updateBluetoothActionProcess: ")
    }
    
    
}


extension TestWiFiConnectionViewController: BluetoothPolingProtocol {
    
    func successfullyReadCharacteristic(characteristic: CBCharacteristic, readValue: Data?) {
        print("TestWiFi:successfullyReadCharacteristic: ")
    }
    
    
    func successfullyWrittenInCharacteristic(characteristic: CBCharacteristic, writtenValue: Data) {
        print("TestWiFi:successfullyWrittenInCharacteristic: ")
    }
    
    
    func successfullyWrittenInDescriptor(descriptor: CBDescriptor, writtenValue: Data) {
        print("TestWiFi:successfullyWrittenInDescriptor: ")
    }
    
}


enum TestConnectionMachineState: Int {
    
    case _POLING                    = -1
    
    case _WIFI_CONFIGURING          = 0
    
    case _WIFI_NOT_CONNECTED        = 1
    
    case _WIFI_SSID_FAILED          = 2
    
    case _WIFI_CONNECTING           = 3
    
    case _WIFI_CONNECTED            = 4
    
    case _WIFI_IP_FAILED            = 5
    
    case _WIFI_GET_LOCATION         = 6
    
    case _WIFI_INTERNET_READY       = 7
    
    case _WIFI_TRANSMITING          = 8
    
}
