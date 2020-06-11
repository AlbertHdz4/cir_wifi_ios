//
//  TestController.swift
//  cir_wireless
//
//  Created by softel on 09/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth


class ScanBleController: UIViewController {
    
    // MARK: Constants
    let DEFAULT_SCANNING_TIME: Double = 5
    let REUSABLE_CELL_ID = "cir_wireless"
    let REUSABLE_CELL_NAME = "CirWirelessCell"
    
    
    // MARK: Outlets
    @IBOutlet weak var courtain: CourtainView!
    @IBOutlet weak var cirWirelessTable: UITableView!
    
    
    // MARK: Variables para el escaneo de dispositivos
    var bleScan: BluetoothScan?
    var cirsFound: [CirWirelessModel]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Algunos cambios en las vistas al iniciar
        loadViews()
        registerTableViewCells()
        
        
        // MARK: Comenzamos a escanear
        bleScan = BluetoothScan(filterBy: [BluetoothGattConstants.CBUUID_SERVICE_CIR_WIRELESS],
                                scanningTime: self.DEFAULT_SCANNING_TIME)
        bleScan?.bleScanDelegate = self
        bleScan?.initScan()
    }
    
    
    // MARK: Funciones utiles del propio controler
    private func loadViews () {
        courtain.courtainMessage.text = NSLocalizedString("Scanning Devices", comment: "Scanning BLE Devices")
        cirWirelessTable.backgroundColor = .white
    }
    
    
    private func scanAgain () {
        self.courtain.showCourtain()
        self.bleScan?.initScan()
    }
    
    
    private func registerTableViewCells() {
        
        let cirWirelessCell = UINib(nibName: REUSABLE_CELL_NAME, bundle: nil)
        self.cirWirelessTable.register(cirWirelessCell, forCellReuseIdentifier: REUSABLE_CELL_ID)
        
    }
    // Funciones utiles del propio controler (End)
}


// MARK: Delegados para la tabla de CIRs encontradas
extension ScanBleController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("EXECUTING TABLE VIEW: \(cirsFound?.count ?? 0)")
        return cirsFound?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cirWirelessCell = cirWirelessTable.dequeueReusableCell(withIdentifier: REUSABLE_CELL_ID,
                                                                   for: indexPath) as? CirWirelessCell
        
        cirWirelessCell?.cirWirelessMac.text = (cirsFound?[indexPath.row])?.getCirWirelessMac()
        cirWirelessCell?.cirModel = cirsFound?[indexPath.row]
        
        return cirWirelessCell!
    }
}


extension ScanBleController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        print("indexPath: \(indexPath)")
    }
}
// Delegados para la tabla de CIRs encontradas (End)


// MARK: Scan Devices Protocol
extension ScanBleController: ScanProtocol {
    
    func updateCentralState(newState: CBManagerState) {
        switch newState {
        case .poweredOn:
            print("poweredOn")
            bleScan?.scanDevices()
          
          
        case .poweredOff :
            print("poweredOff")
          
          
        case .resetting :
            print("resetting")
          
          
        case .unauthorized :
            print("unauthorized")
            
            let permissionTitleAlert = NSLocalizedString("BLE Persmission Title Denied",
                                               comment: "Permission needs to be updated")
            
            let persmissionMessageAlert = NSLocalizedString("BLE Persmission Message Denied",
                                                 comment: "Permission needs to be updated")
            
            var permissionPopUp: UIAlertController?
            
            let permissionAlertComponents = AlertComponents(alertTitle: permissionTitleAlert, alertMessage: persmissionMessageAlert)
                        
            let permissionActionComponents = AlertActionComponents(
                buttonTitle: NSLocalizedString("Settings",
                                               comment: "Leads user to setting values"),
                
                buttonHandler: {(_) -> Void in
                    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                    
                    if UIApplication.shared.canOpenURL(settingsUrl!) {
                        UIApplication.shared.open(
                            settingsUrl!,
                            completionHandler: { (success) in
                                permissionPopUp?.dismiss(animated: true, completion: nil)
                          })
                    }
            })
            
            permissionPopUp = PopUpAlert.popUpOneButton(alertCharacteristic: permissionAlertComponents,
                                              buttonCharacteristic: permissionActionComponents)
            
            self.present(permissionPopUp!, animated: true, completion: nil)
          
        case .unknown :
            print("unknown")
          
          
        case .unsupported :
            print("unsupported")
          
          
        default:
            print("\(newState)")
        }
      }
    
    
    func updateScanProcessState(currentStatus: ScanProcess) {
        print("updateScanProcessState: \(currentStatus)")
    }
      
      
    func scanFinished(scannedDevices: [CirWirelessModel]) {
        self.courtain.hideCourtain()
        
        if scannedDevices.count != 0 {
            
            self.cirsFound = scannedDevices
            self.cirWirelessTable.dataSource = self
            self.cirWirelessTable.delegate = self
            self.cirWirelessTable.tableFooterView = UIView()
            
        } else {
            
            let scanAlertTitle = NSLocalizedString("Bluetooth Scanning",
                                               comment: "None Cir Wireless near by")
            
            let scanAlertMessage = NSLocalizedString("Cir's Not Found",
                                                 comment: "None Cir Wireless near by")
            
            var scanResultPopUp: UIAlertController?
            
            let scanAlertComponents = AlertComponents(alertTitle: scanAlertTitle,
                                                  alertMessage: scanAlertMessage)
                        
            let retryActionComponents = AlertActionComponents(
                buttonTitle: NSLocalizedString("Retry",
                                               comment: "Scan again"),
                
                buttonHandler: {(_) -> Void in
                    scanResultPopUp?.dismiss(animated: true, completion: nil)
                    self.scanAgain()
            })
            
            
            let acceptActionComponents = AlertActionComponents(
                buttonTitle: NSLocalizedString("Accept",
                                              comment: "Just to dismiss dialog"),
               
                buttonHandler: {(_) -> Void in
                    scanResultPopUp?.dismiss(animated: true, completion: nil)
            })
            
            scanResultPopUp = try? PopUpAlert.popUpTwoButtons(alertCharacteristic: scanAlertComponents,
                                                              buttonCharacteristic: [acceptActionComponents, retryActionComponents])
        
            
            self.present(scanResultPopUp!, animated: true, completion: nil)
        }
    }
    
      
    func errorOcurred(error: ErrorBluetoothScan) {
        print("errorOcurred: \(error)")
    }
}
// Scan Devices Protocol (End)
