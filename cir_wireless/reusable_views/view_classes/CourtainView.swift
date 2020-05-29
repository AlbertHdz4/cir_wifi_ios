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
    @IBOutlet weak var courtain: UIView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    @IBOutlet weak var courtainMessage: UILabel!
    
    
    let nibName = "Courtain"
    
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
        courtain.isHidden = true
        activityLoader.stopAnimating()
    }
    
    
    func showCourtain () { courtain.isHidden = false }
    
    
    func isCourtainHidden () -> Bool { return courtain.isHidden }
    
    
    func setCourtain (message: String) { courtainMessage.text = message }
}
