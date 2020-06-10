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
        
        // Algunos cambios en las vistas al iniciar
        loadViews()
        
        self.cirWirelessTable.dataSource = self
        self.cirWirelessTable.tableFooterView = UIView()
        
        bleScan = BluetoothScan(filterBy: [BluetoothGattConstants.CBUUID_SERVICE_CIR_WIRELESS])
        bleScan?.bleScanDelegate = self
        bleScan?.initScan()
        
    }
    
    
    // MARK: Funciones utiles del propio controler
    private func loadViews () {
        courtain.courtainMessage.text = NSLocalizedString("Scanning Devices", comment: "Scanning BLE Devices")
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
        
        return cirsFound?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cirWirelessCell = cirWirelessTable.dequeueReusableCell(withIdentifier: REUSABLE_CELL_ID)
        
        if cirWirelessCell == nil {
            cirWirelessCell = UITableViewCell()
        }
        
        
        return cirWirelessCell!
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
            
            let titleAlert = NSLocalizedString("BLE Persmission Title Denied", comment: "Permission needs to be updated")
            
            let messageAlert = NSLocalizedString("BLE Persmission Message Denied", comment: "Permission needs to be updated")
            
            var popUp: UIAlertController?
            
            let alertComponents = AlertComponents(alertTitle: titleAlert, alertMessage: messageAlert)
                        
            let actionComponents = AlertActionComponents(
                buttonTitle: NSLocalizedString("Settings", comment: "Leads user to setting values"),
                buttonHandler: {(_) -> Void in
                    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                    
                    if UIApplication.shared.canOpenURL(settingsUrl!) {
                        UIApplication.shared.open(
                            settingsUrl!,
                            completionHandler: { (success) in
                                popUp?.dismiss(animated: true, completion: nil)
                          })
                    }
            })
            
            popUp = PopUpAlert.popUpOneButton(alertCharacteristic: alertComponents,
                                              buttonCharacteristic: actionComponents)
            
            self.present(popUp!, animated: true, completion: nil)
          
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
        
        self.cirsFound = scannedDevices
        self.courtain.hideCourtain()
        
        print("updateScanProcessState: \(self.cirsFound!.count)")
    }
      
      
    func errorOcurred(error: ErrorBluetoothScan) {
        print("errorOcurred: \(error)")
    }

}
// Scan Devices Protocol (End)
