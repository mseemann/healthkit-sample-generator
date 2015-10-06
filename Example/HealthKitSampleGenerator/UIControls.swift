//
//  UIControls.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 06.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

public class BaselineTextField : UITextField {
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        borderStyle = UITextBorderStyle.None
        
    }
 
    override public func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(ctx, 1.0);
        
        CGContextSetRGBStrokeColor(ctx, 0.6, 0.6, 0.6, 1);
        CGContextMoveToPoint(ctx, 0, rect.size.height);
        CGContextAddLineToPoint( ctx, rect.size.width, rect.size.height);
        
        CGContextStrokePath(ctx);
    }
}