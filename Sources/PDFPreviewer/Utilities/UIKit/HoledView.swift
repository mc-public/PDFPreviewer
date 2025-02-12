//
//  CAHoledLayer.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/9/29.
//

#if os(iOS)

import UIKit

class HoledView: UIView {
    
    override class var layerClass: AnyClass {
        CAPlainLayer.self
    }
    /// The visible rect about current visible layer.
    var visibleRect: CGRect {
        self.bounds.intersection(_visibleRect ?? self.bounds)
    }
    
    private var _visibleRect: CGRect?
    
    /// The background layer of current view.
    @MainActor
    var backgroundLayer: CAPlainShapeLayer {
        didSet {
            if oldValue === backgroundLayer { return }
            oldValue.removeFromSuperlayer()
            layer.addSublayer(backgroundLayer)
            backgroundLayer.fillRule = .evenOdd
            backgroundLayer.fillColor = UIColor.clear.cgColor
            backgroundLayer.zPosition = 1
            if _visibleRect != nil {
                self.updateVisibleHoleRect(in: visibleRect)
            }
        }
    }
    /// The visible layer of current view.
    @MainActor
    var visibleLayer: CALayer {
        didSet {
            if oldValue === visibleLayer { return }
            oldValue.removeFromSuperlayer()
            layer.addSublayer(visibleLayer)
            visibleLayer.zPosition = 0
        }
    }
    
    /// Creates a view with the specified frame rectangle.
    override init(frame: CGRect) {
        backgroundLayer = .init()
        visibleLayer = .init()
        super.init(frame: frame)
    }
    /// Creates a view from data in an unarchiver.
    required init?(coder: NSCoder) {
        backgroundLayer = .init()
        visibleLayer = .init()
        super.init(coder: coder)
    }
    
    private func commonInit() {
        layer.addSublayer(backgroundLayer)
        layer.addSublayer(visibleLayer)
        backgroundLayer.fillRule = .evenOdd
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.zPosition = 1
        visibleLayer.zPosition = 0
    }
    
    /// Update the visible rect about the visible Layer.
    ///
    /// - Parameter frame: `CGRect` to be displayed in the visible layer.
    func updateVisibleHoleRect(in frame: CGRect) {
        self._visibleRect = frame
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        let path: CGMutablePath = CGMutablePath()
        path.addRect(self.bounds)
        path.addRect(frame)
        maskLayer.path = path
        maskLayer.fillRule = .evenOdd
        self.backgroundLayer.mask = maskLayer
    }
    
    /// Tells the delegate a layer's bounds have changed.
    override func layoutSublayers(of layer: CALayer) {
        self.backgroundLayer.frame = self.bounds
        self.visibleLayer.frame = self.bounds
        super.layoutSublayers(of: layer)
    }
}
#endif
