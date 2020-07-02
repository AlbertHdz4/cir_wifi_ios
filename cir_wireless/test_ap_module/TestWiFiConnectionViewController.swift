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
    
    var cipStatus                       : Int = -1
    
    
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
    @IBOutlet weak var cwMacLabel       : UILabel!
    @IBOutlet weak var apIcon           : UIImageView!
    @IBOutlet weak var internetIcon     : UIImageView!
    @IBOutlet weak var dataIcon         : UIImageView!
    
    
    // Ciclo de vida de la vista --------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let _ = bluetoothActions {
            
            bluetoothActions?.bluetoothBaseDelegate  = self
            bluetoothActions?.bluetoothPolingDelegate   = self
            bluetoothActions?.setCirWirelessNotifyCharacteristic(enable: true,
                                                                 notifyCharacteristic: cwProtocolNotificationCharac!)
            machineState = ._CHECK_WIFI_STATUS
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
            
        case ._CHECK_WIFI_STATUS:
            print("_CHECK_WIFI_STATUS")
            
            
        case ._SET_MODE:
            print("_SET_MODE")
            
        case ._GET_CONFIG_AP:
            print("_GET_CONFIG_AP")
            
        case ._GET_STATUS_AP:
            print("_GET_STATUS_AP")
            
        case ._GET_IP:
            print("_GET_IP")
            
        case ._GET_PING:
            print("_GET_PING")
            
        case ._PING:
            print("_PING")
            
        case ._DATA_CONNECTION:
            print("_DATA_CONNECTION")
            
        default:
            break
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
    
    case _POLING
    
    case _WIFI_CONFIGURING
    
    case _WIFI_NOT_CONNECTED
    
    case _WIFI_SSID_FAILED
    
    case _WIFI_CONNECTING
    
    case _WIFI_CONNECTED
    
    case _WIFI_IP_FAILED
    
    case _WIFI_GET_LOCATION
    
    case _WIFI_INTERNET_READY
    
    case _WIFI_TRANSMITING
    
    case _CHECK_WIFI_STATUS
    
    case _SET_MODE
    
    case _GET_CONFIG_AP
    
    case _GET_STATUS_AP
    
    case _GET_IP
    
    case _GET_PING
    
    case _PING
    
    case _DATA_CONNECTION
}
