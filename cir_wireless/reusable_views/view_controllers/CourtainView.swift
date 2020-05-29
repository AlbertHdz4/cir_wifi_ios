//
//  CourtainView.swift
//  cir_wireless
//
//  Created by softel on 29/05/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit

class CourtainView: UIView {
    
    
    // Outlets
    @IBOutlet weak var courtainView: UIView!
    
    
    // Useful vars / lets
    let nibName = "Courtain"
    
    
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    func commonInit () {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    
    func hideCourtain () { courtainView.isHidden = true }
    
    
    func showCourtain () { courtainView.isHidden = false }
    
    
    func courtainState () -> Bool { return courtainView.isHidden }
}
