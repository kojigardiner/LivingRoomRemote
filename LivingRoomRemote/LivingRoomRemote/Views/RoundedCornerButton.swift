//
//  RoundedCornerButton.swift
//  LivingRoomRemote
//
//  Created by Koji Gardiner on 9/28/17.
//  Copyright © 2017 Koji Gardiner. All rights reserved.
//

import UIKit

class RoundedCornerButton: UIButton {

    let colorNormal: CGColor = #colorLiteral(red: 0.2899576556, green: 0.2899576556, blue: 0.2899576556, alpha: 0.5)
    let colorHighlighted: CGColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 0.5)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10.0
        layer.backgroundColor = colorNormal
    }
    
    override var isHighlighted: Bool {
        didSet {
            layer.backgroundColor = isHighlighted ? colorHighlighted : colorNormal
        }
    }
}
