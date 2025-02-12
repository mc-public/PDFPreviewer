//
//  CALayer+Plain.swift
//
//
//  Created by 孟超 on 2024/9/16.
//

#if os(iOS)
import Foundation
import QuartzCore
import UIKit

class CAPlainLayer: CALayer {
    override class func defaultAction(forKey event: String) -> (any CAAction)? {
        nil
    }
}

class CAPlainShapeLayer: CAShapeLayer {
    override class func defaultAction(forKey event: String) -> (any CAAction)? {
        nil
    }
}


class CAPlainTiledLayer: CATiledLayer {
    override class func fadeDuration() -> CFTimeInterval {
        .zero
    }
    
    func prepareForContent() {
        self.contents = nil
        self.setNeedsDisplay(self.bounds)
    }
}


class CAPlainTransparentLayer: CAPlainLayer {
    
    override init() {
        super.init()
        self.commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        self.commonInit()
    }
    
    
    func commonInit() {
        self.backgroundColor = UIColor.clear.cgColor
    }
}

extension CALayer {
    /// Remove all sublayers of current view.
    func removeSublayers() {
        self.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
}

#endif
