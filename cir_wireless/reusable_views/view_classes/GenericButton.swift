//
//  GenericButton.swift
//  cir_wireless
//
//  Created by softel on 01/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit

class GenericButton: UIView {

    let nibName = "GenericBtnCustom"

    // Outlets
    @IBOutlet var genericBtnContainer: UIView!
    @IBOutlet weak var genericBtnImg: UIButton!
    @IBOutlet weak var genericBtnText: UILabel!
    
    var contentDescription: ContentDescription = .noDescription
    
    // Initialization
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

        return view
    }
    
    
    // Functions
    func setGenericButtonImage (image: UIImage) {
        genericBtnImg.setImage(image, for: .normal)
    }
    
    
    func setGenericButtonTitle (title: String) {
        genericBtnText.text = title
    }
    
    
    func hideGenericBtn () {
        genericBtnContainer.isHidden = true
    }
    
    
    func showGenericBtn () {
        genericBtnContainer.isHidden = false
    }
    
    
    func setGenericBtnDescription (description: ContentDescription) {
        contentDescription = description
    }
    
    
    func getGenericBtnDescription () -> ContentDescription {
        return contentDescription
    }
}
