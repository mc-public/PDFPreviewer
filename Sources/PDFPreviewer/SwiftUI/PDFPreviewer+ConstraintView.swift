//
//  PDFPreviewer+ConstraintView.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/16.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import PDFKit

@MainActor
class PDFDocumentConstraintView: UIView {
    
    private let documentView: PDFDocumentScrollView
    private var editInteraction: UIEditMenuInteraction?
    private var longPressGesture: UILongPressGestureRecognizer?
    private weak var previewerModel: PDFPreviewerModel?
    
    init(documentView: PDFDocumentScrollView) {
        self.documentView = documentView
        super.init(frame: .zero)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    func addPreviewerModel(_ model: PDFPreviewerModel) {
        self.previewerModel = model
    }
    
}

//FIXME: Long press abnormal.

extension PDFDocumentConstraintView: UIGestureRecognizerDelegate {
    
    private func commonInit() {
        self.isUserInteractionEnabled = true
        // Add interaction
//        let interaction = UIEditMenuInteraction(delegate: self)
//        self.editInteraction = interaction
//        self.addInteraction(interaction)
        
       
        // Set view horizory
        self.documentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.documentView)
        self.documentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        self.documentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.documentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.documentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // Add Gesture
//        let gesture = UILongPressGestureRecognizer()
//        self.longPressGesture = gesture
//        gesture.addTarget(self, action: #selector(self.didLongPress(_:)))
//        gesture.delegate = self
//        self.addGestureRecognizer(gesture)
    }
    
//    @objc
//    private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
//        let position = gesture.location(in: self.documentView)
//        if !self.documentView.bounds.contains(position) {
//            return
//        }
//        let page = self.documentView.page(for: position, nearest: false)
//        if page != nil && self.previewerModel?.interactionDelegate?.showMenu == nil {
//            return
//        }
//        if page == nil && self.previewerModel?.interactionDelegate?.showMenuOutsidePages == nil {
//            return
//        }
//        let editMenuConfig = UIEditMenuConfiguration(identifier: nil, sourcePoint: position)
//        self.editInteraction?.presentEditMenu(with: editMenuConfig)
//    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        true
//    }
    
    func updateTapGesture() {
        guard let action = previewerModel?.interactionDelegate?.didDoubleTap else {
            self.documentView.doubleTapAction = nil
            return
        }
        self.documentView.doubleTapAction = action
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === longPressGesture {
            return true
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}

extension PDFDocumentConstraintView: UIEditMenuInteractionDelegate {
//    nonisolated func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
//        MainActor.assumeIsolated { () -> UIMenu? in
//            let position = interaction.location(in: self.documentView)
//            if !self.documentView.bounds.contains(position) {
//                return nil
//            }
//            guard let page = self.documentView.page(for: position, nearest: false) as? PDFPageModel else {
//                return self.previewerModel?.interactionDelegate?.showMenuOutsidePages?(at: position)
//            }
//            let pagePoint = self.documentView.convert(position, to: page)
//            let tapPosition = PDFPreviewerModel.DocumentPosition(page: page, point: pagePoint)
//            return self.previewerModel?.interactionDelegate?.showMenu?(at: tapPosition)
//        }
//    }
}



#endif
