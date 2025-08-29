//
//  ConfigurationController.swift
//  cir_wireless
//
//  Created by softel on 15/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData


class ConfigurationController: UIViewController {
    
    let SEGMENTED_CONTROL_VALUES    = [NSLocalizedString("Lock Label", comment: "First value of segmented control"),
                                       NSLocalizedString("Configuration Label", comment: "Second value of segmented control")]
    
    
    var isCirConnected              = false
    var isBluetoothOn               = false
    var isCIR232                    = false
    
    
    var cirWireless                             : CirWirelessModel?
    var bluetoothActions                        : CoreBluetoothActions?
    var quickCommandResponseState               : QuickCommandResponseState = ._WAITING
    
    
    // MARK: Servicios bluetooth de la cir wireless
    var cWInfoService                           : CBService?
    var cwProtocolService                       : CBService?
    var cWQuickCommandsService                  : CBService?
    
    
    // MARK: Caracteristicas bluetooth de la cir wireless
    var cwInfoCharacteristic                    : CBCharacteristic?
    var cwQuickCommandsCharacteristic           : CBCharacteristic?
    var cwProtocolNotificationCharac            : CBCharacteristic?
    var cwProtocolWriteCharacteristic           : CBCharacteristic?
    
    
    var connectingAlert                         : UIAlertController?
    var sendingCommandAlert                     : UIAlertController?
    
    
    var responseAlert                           : UIAlertController!
    var responseTitle                           : String!
    var responseMessage                         : String!
    
    
    // Outlets
    @IBOutlet weak var connectionStatus         : UILabel!
    @IBOutlet weak var cirWirelessMac           : UILabel!
    @IBOutlet weak var configurationSelector    : UISegmentedControl!
    @IBOutlet weak var containerLockBtns        : UIStackView!
    @IBOutlet weak var containerReloadBtn       : UIStackView!
    @IBOutlet weak var containerConfigBtns      : UIStackView!
    @IBOutlet weak var lockBtn                  : RoundButton!
    @IBOutlet weak var unlockBtn                : RoundButton!
    @IBOutlet weak var reloadBtn                : RoundButton!
    @IBOutlet weak var configureBtn             : RoundButton!
    @IBOutlet weak var testBtn                  : RoundButton!
    
    
    // Ciclo de vida de la vista --------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Algunos cambios necesarios antes de iniciar
        loadViews()
        
        if let _ = cirWireless, let _ = bluetoothActions {
            
            popUpConnectingCir()
            isCIR232 = cirWireless?.beacon?.beaconModelName == "CIR 232"
            bluetoothActions?.bluetoothConnectionDelegate = self
            bluetoothActions?.bluetoothQuickCommandsDelegate = self
            bluetoothActions?.connectCirWireless(peripheralToConnect: cirWireless!.peripheral!)
            
        } else {
            popUpErrorCirConnection()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        bluetoothActions?.disconnectCirWireless()
    }
    
    // ----------------------------------------------------------------------
    
    private func loadViews () {
        
        let preferredLanguage = NSLocale.preferredLanguages[0]
        
        if preferredLanguage.starts(with: "en") {
            
            lockBtn.setImage(UIImage(named: "btn_lock.pdf"), for: .normal)
            unlockBtn.setImage(UIImage(named: "btn_unlock.pdf"), for: .normal)
            reloadBtn.setImage(UIImage(named: "btn_reload.pdf"), for: .normal)
            configureBtn.setImage(UIImage(named: "btn_setup.pdf"), for: .normal)
            testBtn.setImage(UIImage(named: "btn_test.pdf"), for: .normal)
            
        } else {
            
            lockBtn.setImage(UIImage(named: "btn_bloquear.pdf"), for: .normal)
            unlockBtn.setImage(UIImage(named: "btn_desbloquear.pdf"), for: .normal)
            reloadBtn.setImage(UIImage(named: "btn_recargar.pdf"), for: .normal)
            configureBtn.setImage(UIImage(named: "btn_configuracion.pdf"), for: .normal)
            testBtn.setImage(UIImage(named: "btn_probar.pdf"), for: .normal)
            
        }
        
        configurationSelector.setTitle(SEGMENTED_CONTROL_VALUES[0], forSegmentAt: 0)
        configurationSelector.setTitle(SEGMENTED_CONTROL_VALUES[1], forSegmentAt: 1)
        popUpSendingCommand()
    }
    
    
    private func goBackToRootController () {
        bluetoothActions?.disconnectCirWireless()
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    private func validateFirmwareVersion (firmwareValue: Data) {
        let firmwareInt: Int = Int(String(firmwareValue[0]) + String(firmwareValue[1]) + String(firmwareValue[2]) + String(firmwareValue[3])) ?? 0
        
        print("firmware int: \(firmwareInt)")
        connectingAlert?.dismiss(animated: true, completion: nil)
        
        if isAValidFirmware(firmwareVersion: firmwareInt) {
            print("validateFirmwareVersion: \(isAValidFirmware(firmwareVersion: firmwareInt))")
            // Habilitamos la caracteristica de notificacion
            updateCirDate()
            connectionStatus.text = NSLocalizedString("Device Connected", comment: "Device is now connected")
            cirWirelessMac.text = self.cirWireless?.getCirWirelessMac()
            
        } else {
            
            popUpNotValidFirmware(firmwareVersion: firmwareInt)
            
        }
    }
    
    
    private func getSupportedFirmwares () -> [Int] {
        var supportedFirmwares = [Int] ()
        
        let fetchRequest = NSFetchRequest <Firmwares> (entityName: "Firmwares")

        do {
            let firmwares = try CoreDataManager.shared.viewContext.fetch(fetchRequest)
            
            print("getSupportedFirmwares: \(firmwares)")
            
            for supportedFirmware in firmwares {
                print("Supported firmwares: \(supportedFirmware.firmware_version!) ")
                supportedFirmwares.append(Int(supportedFirmware.firmware_version!)!)
            }
            
        } catch {
            print("Error al recuperar datos: \(error)")
        }
        
        return supportedFirmwares
    }
    
    
    private func isAValidFirmware (firmwareVersion: Int) -> Bool {
        let supportedFirmwares  = self.getSupportedFirmwares()
        let existsLocally       = self.checkLocalFirmwares(firmwareVersion: firmwareVersion)
        let existsRemotelly     = (!supportedFirmwares.isEmpty && supportedFirmwares.contains(firmwareVersion))
        let isSupported         = (existsLocally || existsRemotelly)
        
        print("FIRMWARE", firmwareVersion)
        print("existsLocally", existsLocally)
        print("existsRemotelly", existsRemotelly)
        print("isSupported", isSupported)

        return isSupported
    }
    
    
    private func checkLocalFirmwares (firmwareVersion: Int) -> Bool {
        return (firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_350.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_351.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_352.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_353.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_354.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_355.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_357.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_360.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_363.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_367.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_382.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_387.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_388.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_401.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_402.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_500.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_502.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_503.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_504.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_427.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_505.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_515.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_952.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_1036.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_361.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_366.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_526.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_961.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_966.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_1046.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_499.rawValue ||
                firmwareVersion == BluetoothGattConstants.AllowedFirmwares._FIRMWARE_410.rawValue)
    }
    
    
    // Actualizacion y lectura de fecha la CIR Wireless -----------------------------------
    private func updateCirDate () {
        
        quickCommandResponseState = ._SET_DATE
        let currentDate = DatePackage.getDatePackage().fullPackage
        let commandDate = CirWirelessCommands.setDateCommand(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!, dateBytes: currentDate!)
        bluetoothActions?.writeCirWirelessCharacteristic(command: commandDate, characteristic: cwQuickCommandsCharacteristic!, type: .withoutResponse)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.readChar), userInfo: nil, repeats: false) // La CIR necesita tiempo para escribir
        
    }
    
    
    private func readCirDate () {
        
        quickCommandResponseState = ._READ_DATE
        let commandReadDate = CirWirelessCommands.readDateCommand(cirWirelessMac: (cirWireless?.getCirWirelessMacBytes())!)
        bluetoothActions?.writeCirWirelessCharacteristic(command: commandReadDate, characteristic: cwQuickCommandsCharacteristic!, type: .withoutResponse)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.readChar), userInfo: nil, repeats: false) // La CIR necesita tiempo para escribir
    }
    // ------------------------------------------------------------------------------------
    
    
    private func validateQuickCommandResponse (quickCommandResponse: QuickCommandResponse) {
        
        if quickCommandResponse.isValid() {
            
            if quickCommandResponseState == ._LOCKING ||
                quickCommandResponseState == ._UNLOCKING ||
                quickCommandResponseState == ._RELOADING {
                
                if quickCommandResponse.response != QuickCommandReponses._LOCK_DISABLED.rawValue {
                    responseTitle = NSLocalizedString("Option Success", comment: "Command successfully sent")
                    
                    switch quickCommandResponseState {
                    case ._LOCKING:
                        responseMessage = NSLocalizedString("Locked", comment: "Lock is closed")
                        
                    case ._UNLOCKING:
                        responseMessage = NSLocalizedString("Unlocked", comment: "Lock is opened")
                        
                    case ._RELOADING:
                        responseMessage = NSLocalizedString("Reload Enabled", comment: "Reload enabled")
                        
                    default:
                        break
                    }
                    
                } else {
                    
                    switch quickCommandResponseState {
                    case ._LOCKING, ._UNLOCKING:
                        responseTitle = NSLocalizedString("Option Disabled", comment: "Lock is disabled or unavailble by hardware or firmware")
                        responseMessage = NSLocalizedString("Lock Disabled", comment: "Lock is disabled or unavailble by hardware or firmware")
                                     
                    case ._RELOADING:
                        responseTitle = NSLocalizedString("Option Disabled", comment: "Reload is disabled or unavailble by hardware or firmware")
                        responseMessage = NSLocalizedString("Reload Disabled", comment: "Reload is disabled or unavailble by hardware or firmware")
                                  
                    case ._WAITING:
                        print("Waiting for command")
                        
                    default :
                        break
                    }
                    
                }
            } else if // quickCommandResponseState == ._READ_DATE ||
                        quickCommandResponseState == ._SET_DATE {
                
                print("Implements for ._READ_DATE if neccessary ...")
                
                // Esto solo es para el caso de ._SET_DATE
                responseTitle = NSLocalizedString("Set Date Title", comment: "Date updated")
                responseMessage = NSLocalizedString("Set Date Message", comment: "Date updated")
            }
            
        } else {
            responseTitle = NSLocalizedString("Error Ocurred Title", comment: "")
            responseMessage = NSLocalizedString("Error Ocurred Message", comment: "")
        }
        
        responseAlert = popUpCommandResponse(title: responseTitle, message: responseMessage, buttonHandler: { _ in
            self.responseAlert.dismiss(animated: true, completion: nil)
        })
    }
    
    
    private func presentPopUp () {
        
        if quickCommandResponseState != ._WAITING {
            
            self.present(responseAlert, animated: true, completion: nil)
            quickCommandResponseState = ._WAITING
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? AccessPointViewController {
            
            destination.cirWireless                     = self.cirWireless
            destination.bluetoothActions                = self.bluetoothActions
            destination.cwProtocolService               = self.cwProtocolService
            destination.cwProtocolNotificationCharac    = self.cwProtocolNotificationCharac
            destination.cwProtocolWriteCharacteristic   = self.cwProtocolWriteCharacteristic
            
        } else if let destination = segue.destination as? TestWiFiConnectionViewController {
            
            destination.cirWireless                     = self.cirWireless
            destination.bluetoothActions                = self.bluetoothActions
            destination.cwProtocolService               = self.cwProtocolService
            destination.cwProtocolNotificationCharac    = self.cwProtocolNotificationCharac
            destination.cwProtocolWriteCharacteristic   = self.cwProtocolWriteCharacteristic
            
        }
    }
    
    
    // Outlet actions --------------------------------------------------
    @IBAction func selectedSegment(_ sender: Any) {
        if configurationSelector.selectedSegmentIndex == 0 {
            
            containerConfigBtns.hideWithOppacity(duration: 0.2, delay: 0.1, completion: {_ in
                self.containerConfigBtns.isHidden   = true
                self.containerLockBtns.isHidden     = false
                self.containerReloadBtn.isHidden    = false
                self.containerLockBtns.showWithOppacity(duration: 0.2, delay: 0.1, completion: nil)
                self.containerReloadBtn.showWithOppacity(duration: 0.2, delay: 0.1, completion: nil)
                
            })
            
        } else {
            
            if (!isCIR232) {
                
                containerLockBtns.hideWithOppacity(duration: 0.2, delay: 0.1, completion: nil)
                containerReloadBtn.hideWithOppacity(duration: 0.2, delay: 0.1, completion: {_ in
                    self.containerLockBtns.isHidden     = true
                    self.containerReloadBtn.isHidden    = true
                    self.containerConfigBtns.isHidden   = false
                    self.containerConfigBtns.showWithOppacity(duration: 0.2, delay: 0.1, completion: nil)
                })
                
            } else {
                
                popUpUnavailableOption()
            }
        }
    }
    
    
    @IBAction func lockFridge (_ sender: Any) {
        self.present(sendingCommandAlert!, animated: true, completion: nil)
        let command = CirWirelessCommands.closeLockCommand(cirWirelessMac: cirWireless!.getCirWirelessMacBytes()) // Comando ya encriptado
        quickCommandResponseState = ._LOCKING
        bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwQuickCommandsCharacteristic!, type: .withoutResponse)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.readChar), userInfo: nil, repeats: false) // La CIR necesita tiempo para escribir
    }
    
    
    @IBAction func unlockFridge (_ sender: Any) {
        self.present(sendingCommandAlert!, animated: true, completion: nil)
        let command = CirWirelessCommands.openLockCommand(cirWirelessMac: cirWireless!.getCirWirelessMacBytes()) // Comando ya encriptado
        quickCommandResponseState = ._UNLOCKING
        bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwQuickCommandsCharacteristic!, type: .withoutResponse)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.readChar), userInfo: nil, repeats: false) // La CIR necesita tiempo para escribir
    }
    
    
    @IBAction func realodFridge (_ sender: Any) {
        self.present(sendingCommandAlert!, animated: true, completion: nil)
        let command = CirWirelessCommands.reloadFridgeCommand(cirWirelessMac: cirWireless!.getCirWirelessMacBytes()) // Comando ya encriptado
        quickCommandResponseState = ._RELOADING
        bluetoothActions?.writeCirWirelessCharacteristic(command: command, characteristic: cwQuickCommandsCharacteristic!, type: .withoutResponse)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.readChar), userInfo: nil, repeats: false) // La CIR necesita tiempo para escribir
    }
    
    
    @objc private func readChar () {
        bluetoothActions?.readCirWirelessCharacteristic(characteristic: cwQuickCommandsCharacteristic!)
    }
    
    
    @IBAction func configWiFiConnection (_ sender: Any) {
        self.performSegue(withIdentifier: ControllerIdentifiers.vcAccessPoints.rawValue, sender: self)
    }
    
    
    @IBAction func testWiFiConnection (_ sender: Any) {
        self.performSegue(withIdentifier: ControllerIdentifiers.vcTestConenction.rawValue, sender: self)
    }
    // ------------------------------------------------------------
    
    
    // Pop up area :D ---------------------------------------------
    private func popUpNotValidFirmware (firmwareVersion: Int) {
        var firmwareNotValid: UIAlertController?
        
        let fwNotValidTitle         = NSLocalizedString("Firmware Invalid Title", comment: "If the firmware is not valid")
        let fwNotValidMessage       = NSLocalizedString("Firmware Invalid Message", comment: "Message")
        let fwNotValidComponents    = AlertComponents(alertTitle: fwNotValidTitle, alertMessage: fwNotValidMessage + ". Firmware: \(firmwareVersion).")
        let fwNotValidAction        = AlertActionComponents(buttonTitle: NSLocalizedString("Accept", comment: "Accept"), buttonHandler: {_ in
            firmwareNotValid?.dismiss(animated: true, completion: nil)
            self.goBackToRootController()
        })
        
        firmwareNotValid = PopUpAlert.popUpOneButton(alertCharacteristic: fwNotValidComponents, buttonCharacteristic: fwNotValidAction)
        self.present(firmwareNotValid!, animated: true, completion: nil)
    }
    
    
    private func popUpErrorCirConnection () {
        var errorCirAlert: UIAlertController?
    
        let errorCirAlertTitle          = NSLocalizedString("Connection Error Title", comment: "In case the passed parameter were null")
        let errorCirAlertMessage        = NSLocalizedString("Connection Error Message", comment: "Message")
        let errorCirAlertComponents     = AlertComponents(alertTitle: errorCirAlertTitle, alertMessage: errorCirAlertMessage)
        let errorCirAlertAction         = AlertActionComponents(buttonTitle: NSLocalizedString("Accept", comment: "Accept"), buttonHandler: { _ in
            errorCirAlert?.dismiss(animated: true, completion: nil)
            self.goBackToRootController()
        })
        
        errorCirAlert = PopUpAlert.popUpOneButton(alertCharacteristic: errorCirAlertComponents, buttonCharacteristic: errorCirAlertAction)
        
        self.present(errorCirAlert!, animated: true, completion: nil)
        
    }
    
    
    private func popUpSendingCommand () {
        let sendingCommandTitle     = NSLocalizedString("Sending Command Title", comment: "Present when command is being sent")
        let sendingCommandMessage   = NSLocalizedString("Please Wait", comment: "Wait ...")
        let sendingAlertComponents  = AlertComponents(alertTitle: sendingCommandTitle, alertMessage: sendingCommandMessage)
        
        sendingCommandAlert = PopUpAlert.popUp(alertCharacteristic: sendingAlertComponents)
    }
    
    
    private func popUpCommandResponse (title: String, message: String, buttonHandler: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let commandResponseAlert: UIAlertController!
        let commandResponseAlertComponents  =  AlertComponents(alertTitle: title, alertMessage: message)
        let commandResponseAlertAction      = AlertActionComponents(buttonTitle: NSLocalizedString("Accept", comment: "Accept"), buttonHandler: buttonHandler)
        
        commandResponseAlert = PopUpAlert.popUpOneButton(alertCharacteristic: commandResponseAlertComponents, buttonCharacteristic: commandResponseAlertAction)
        
        return commandResponseAlert
    }
    
    
    private func popUpConnectingCir () {
    
        let connectingAlertTitle        = NSLocalizedString("Connecting Device Title", comment: "Connectig with CIR Wireless")
        let connectingAlertMessage      = NSLocalizedString("Please Wait", comment: "Message")
        let connectingAlertComponents   = AlertComponents(alertTitle: connectingAlertTitle, alertMessage: connectingAlertMessage)
        let connectingAlertAction       = AlertActionComponents(buttonTitle: NSLocalizedString("Cancel", comment: "Cancel"), buttonHandler: { _ in
            self.connectingAlert?.dismiss(animated: true, completion: nil)
            self.goBackToRootController()
        })
        
        connectingAlert = PopUpAlert.popUpOneButton(alertCharacteristic: connectingAlertComponents, buttonCharacteristic: connectingAlertAction)
        
        self.present(connectingAlert!, animated: true, completion: nil)
    }
    
    
    private func popUpUnavailableOption () {
        var unavailableOptionAlert: UIAlertController?
    
        let unavailableOptionAlertTitle          = NSLocalizedString("Unavailable Option Title", comment: "")
        let unavailableOptionAlertMessage        = NSLocalizedString("Unavailable Option Message", comment: "")
        let unavailableOptionAlertComponents     = AlertComponents(alertTitle: unavailableOptionAlertTitle, alertMessage: unavailableOptionAlertMessage)
        let unavailableOptionAlertAction         = AlertActionComponents(buttonTitle: NSLocalizedString("Accept", comment: "Accept"), buttonHandler: { _ in
            unavailableOptionAlert?.dismiss(animated: true, completion: nil)
            self.configurationSelector.selectedSegmentIndex = 0
        })
        
        unavailableOptionAlert = PopUpAlert.popUpOneButton(alertCharacteristic: unavailableOptionAlertComponents, buttonCharacteristic: unavailableOptionAlertAction)
        
        self.present(unavailableOptionAlert!, animated: true, completion: nil)    }
    // --------------------------------------------------------------
}


// Protocolo de comunicacion entre Bluetooth Actions y nuestro controlador ------------------------------------
extension ConfigurationController: BluetoothConnectionProtocol {

    
    func servicesAvailable(services: [CBService]?) {
        
        if let _ = services {
            
            // MARK: Se obtienen los servicios de la tarjeta CIR Wireless
            for service in services! {
                let serviceUuid = service.uuid.uuidString
                
                
                if serviceUuid == BluetoothGattConstants.CBUUID_DEVICE_INFO_SERVICE {
                    
                    self.cWInfoService = service
                   
                } else if serviceUuid == BluetoothGattConstants.CBUUID_QUICK_COMMANDS_SERVICE {
                   
                    self.cWQuickCommandsService = service
               
                } else if serviceUuid == BluetoothGattConstants.CBUUID_CIR_NAMA_SERVICE {
                   
                    self.cwProtocolService = service
                                  
                }
            }
            
            
            if let _ = self.cWInfoService {
                
                bluetoothActions?.discoverCirWirelessCharacteristics(serviceToBeExamined: cWInfoService!,
                                                                     specificCharacteristics: [CBUUID(string: BluetoothGattConstants.CBUUID_DEVICE_INFO_CHARACTERISTIC)])
            }
            
            if let _ = self.cWQuickCommandsService {
                
                bluetoothActions?.discoverCirWirelessCharacteristics(serviceToBeExamined: cWQuickCommandsService!,
                                                                     specificCharacteristics: [CBUUID(string: BluetoothGattConstants.CBUUID_QUICK_COMMANDS_CHARACTERISTIC)])
            }
            
            
            if let _ = self.cwProtocolService {
                
                bluetoothActions?.discoverCirWirelessCharacteristics(serviceToBeExamined: cwProtocolService!,
                                                                     specificCharacteristics: [CBUUID(string: BluetoothGattConstants.CBUUID_CIR_NAMA_WRITE_CHARACTERISTIC),
                                                                                               CBUUID(string: BluetoothGattConstants.CBUUID_CIR_NAMA_NOTIFY_CHARACTERISTIC)])
            }
        }
    }
    
    
    func characteristicsAvailable(service: CBService, availableCharacteristics characteristics: [CBCharacteristic]) {
        
        for characteristic in characteristics {
            let characteristicUuid = characteristic.uuid.uuidString
               
            if characteristicUuid == BluetoothGattConstants.CBUUID_CIR_NAMA_NOTIFY_CHARACTERISTIC {
                
                self.cwProtocolNotificationCharac = characteristic
            
            } else if characteristicUuid == BluetoothGattConstants.CBUUID_CIR_NAMA_WRITE_CHARACTERISTIC {
                
                self.cwProtocolWriteCharacteristic = characteristic
                
            } else if characteristicUuid == BluetoothGattConstants.CBUUID_QUICK_COMMANDS_CHARACTERISTIC {
                
                self.cwQuickCommandsCharacteristic = characteristic
                
            } else if characteristicUuid == BluetoothGattConstants.CBUUID_DEVICE_INFO_CHARACTERISTIC {
                
                self.cwInfoCharacteristic = characteristic
                
            }
        }
        
        
        if let _ = cwInfoCharacteristic, let _ = cwProtocolNotificationCharac,
            let _ = cwProtocolWriteCharacteristic, let _ = cwQuickCommandsCharacteristic {
            
            // Leemos el firmware de la CIR, solo se permite a dia de hoy la version 3.5.0 en adelante
            bluetoothActions?.readCirWirelessCharacteristic(characteristic: cwInfoCharacteristic!)
        }
    }
    
    
    func updateBluetoothConnectProcess(status: BluetoothConnectionProcess) {
        
        print(status)
        
        switch status {
            
        case .connecting :
            print("connecting")
            
            
        case .connected :
            bluetoothActions?.discoverCirWirelessServices(specificServices: nil)
            
            
        case .disconnecting :
            print("disconnecting")
            
            
        case .disconnected :
            print("disconnected")
            
            
        case .discoveringServicesAndCharacteristics :
            print("discoveringServices")
            
            
        case .connectionFailed :
            print("connectionFailed")
            
            
        case .servicesDiscovered :
            print("servicesDiscovered:")
        
            
        case .characteristicsDiscovered :
            print("characteristicsDiscovered:")
            
        
        case .noneServicesAvailable,
             .noneCharacteristicsAvailable :
            print("noneServicesOrCharacteristics")
            popUpErrorCirConnection()
        
            
        case .successfullyWrittenInCharacteristic,
             .successfullyWrittenInDescriptor:
            break
            
        }
    }
    
    
    func errorConnectionOcurred(error: ErrorConnection) {
        print("error ocurred: \(error)")
    }
}


extension ConfigurationController: BluetoothQuickCommandsProtocol {
    
     func successfullyReadCharacteristic(characteristic: CBCharacteristic, readValue: Data?) {
         // print("successfullyReadCharacteristic:value: \(readValue!.hexDescription)")
         let characteristicUuidString = characteristic.uuid.uuidString
         
         if characteristicUuidString == cwInfoCharacteristic?.uuid.uuidString, let firmwareValue = readValue {
             
             validateFirmwareVersion(firmwareValue: firmwareValue)
    
         } else if characteristicUuidString == cwQuickCommandsCharacteristic?.uuid.uuidString, let response = readValue {

             let qCResponse = QuickCommandResponse(responsePackage: response.hexDescription.hexaToBytes)
             
             sendingCommandAlert?.dismiss(animated: false, completion: {
                 self.validateQuickCommandResponse(quickCommandResponse: qCResponse)
                 self.presentPopUp()
             })
             
         }
     }
     
     
     func successfullyWrittenInCharacteristic(characteristic: CBCharacteristic, writtenValue: Data) {
         bluetoothActions?.readCirWirelessCharacteristic(characteristic: cwQuickCommandsCharacteristic!)
     }
     
     
     func successfullyWrittenInDescriptor(descriptor: CBDescriptor, writtenValue: Data) {
        
     }
     
}
// ---------------------------------------------------------------------------------------------------------


// Estados para esperar la respuesta de Quick Commands -----------------------------------------------------
enum QuickCommandResponseState: String {
    
    case _SET_DATE      = "Set Date"
    
    case _READ_DATE     = "Read Date"
    
    case _UNLOCKING     = "Unlock Fridge"
    
    case _LOCKING       = "Lock Fridge"
    
    case _RELOADING     = "Recharge Fridge"

    case _WAITING       = "Waiting for"
    
}
// ---------------------------------------------------------------------------------------------------------
