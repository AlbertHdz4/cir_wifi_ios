//
//  AboutControllerViewController.swift
//  cir_wireless
//
//  Created by softel on 17/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreData

class AboutViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    @IBAction func firmwaresBtn(_ sender: Any) {
        var firmwaresString = """
        Local firmwares:\n
        """
        
        let firmwares  = self.getSupportedFirmwares()
        print("Supported firmwares: \(firmwares)")
    
        for supportedFirmware in firmwares {
            firmwaresString += "\(supportedFirmware)\n"
        }
        
        print("Firmwares String: \(firmwaresString)")
        // Instanciamos nuestro ViewController "personalizado"
        let dialogVC = CustomDialogViewController()
        dialogVC.textToShow = firmwaresString
        
        // Para que el fondo sea semi-transparente y no ocupe toda la pantalla
        dialogVC.modalPresentationStyle = .overFullScreen
        
        // Presentamos el diálogo
        present(dialogVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nsObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as? String ?? "no available"
        let vrs = NSLocalizedString("Version", comment: "App version")
        versionLabel.text = "\(vrs): \(version)"
    }

    private func getSupportedFirmwares () -> [Int] {
        var supportedFirmwares = [Int] ()
        
        let fetchRequest = NSFetchRequest <Firmwares> (entityName: "Firmwares")

        do {
            let firmwares = try CoreDataManager.shared.viewContext.fetch(fetchRequest)
            for supportedFirmware in firmwares {
                supportedFirmwares.append(Int(supportedFirmware.firmware_version!)!)
            }
            
        } catch {
            print("Error al recuperar datos: \(error)")
        }
        
        return supportedFirmwares
    }
}
