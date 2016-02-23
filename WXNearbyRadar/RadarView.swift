//
//  Radar.swift
//  RadarAnim
//
//  Created by Xin Wu on 2/21/16.
//  Copyright © 2016 Xin Wu. All rights reserved.
//

import UIKit

class RadarView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override class func layerClass() -> AnyClass {
        return GradientAngleCALayer.classForCoder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
        // Change the color of scan animation
        let colors = [UIColor(red: 1, green: 1, blue: 1, alpha: 0),
                      UIColor(red: 1, green: 1, blue: 1, alpha: 0),
                      UIColor(red: 1, green: 1, blue: 1, alpha: 0),
                      UIColor(red: 192/255, green: 57/255, blue: 43/255, alpha: 1.0)]
        
        // AngleGradientLayer by Pavel Ivashkov
        let l = self.layer as! GradientAngleCALayer
        l.colors = colors
        
        // Since our gradient layer is built as an image,
        // we need to scale it to match the display of the device.
        l.contentsScale = UIScreen.mainScreen().scale
        
        l.cornerRadius = CGRectGetWidth(self.bounds) / 2
        
        self.clipsToBounds = true
        self.userInteractionEnabled = false
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
