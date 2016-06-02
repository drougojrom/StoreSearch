//
//  GradientView.swift
//  StoreSearch
//
//  Created by Roman Ustiantcev on 27/05/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        
        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clearColor()
        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    }
    
    override func drawRect(rect: CGRect) {
        
        // 1 - two colors: black and less black
        let components:[CGFloat] = [0, 0, 0, 0.3, 0, 0, 0, 0.7]
        let locations: [CGFloat] = [0, 1]
        
        // 2 - create gradient object
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2)
        
        // 3 - get x and y middle
        let x = CGRectGetMidX(bounds)
        let y = CGRectGetMidY(bounds)
        
        let point = CGPoint(x: x, y: y)
        let radius = max(x, y)
        
        // 4 - draw
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawRadialGradient(context, gradient, point, 0, point, radius, .DrawsAfterEndLocation)
    }

}
