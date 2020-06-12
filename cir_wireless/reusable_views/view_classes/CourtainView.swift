//
//  CourtainView.swift
//  cir_wireless
//
//  Created by softel on 29/05/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit

class CourtainView: UIView {
    
    let nibName = "Courtain"
    
    
    // Outlets
    @IBOutlet weak var courtain: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var courtainMessage: UILabel!
    

    // MARK: Dimensiones de la cortina de carga
    var width: CGFloat?
    var height: CGFloat?
    var xPosition: CGFloat?
    var yPosition: CGFloat?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
     }
    
    
     override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
     }
    
    
     func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
     }
    
    
     func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView

        activityLoader.color = .darkGray
        activityLoader.startAnimating()
        
        return view
     }
    
    
    func hideCourtain () {
        xPosition = courtain.frame.origin.x
        width = courtain.frame.size.width
        height = courtain.frame.size.height
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.courtain.frame = CGRect(x: self.xPosition! - 1000, y: 0, width: self.width!, height: self.height!)
        })
        // courtain.isHidden = true
        activityLoader.stopAnimating()
    }
    
    
    func showCourtain () {
        xPosition = courtain.frame.origin.x
        width = courtain.frame.size.width
        height = courtain.frame.size.height
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.courtain.frame = CGRect(x: self.xPosition! + 1000, y: 0, width: self.width!, height: self.height!)
        })
        
        activityLoader.startAnimating()
    }
    
    
    func isCourtainHidden () -> Bool { return courtain.isHidden }
    
    
    func setCourtain (message: String) { courtainMessage.text = message }
}
