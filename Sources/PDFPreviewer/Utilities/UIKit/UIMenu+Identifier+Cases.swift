//
//  UIMenu+Identifier+Cases.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/10/8.
//

#if os(iOS)

import UIKit

extension UIMenu.Identifier {
    static var allCases: [UIMenu.Identifier] {
        let exts: [UIMenu.Identifier] =  if #available(iOS 17.0, *) {
            [.autoFill]
        } else { [] }
        return [.application, .file, .edit, .view, .window, .help, .about, .preferences, .services, .hide, .quit, .newScene, .openRecent, .close, .print, .document, .undoRedo, .standardEdit, .find, .replace, .share, .textStyle, .spelling, .spellingPanel, .spellingOptions, .substitutions, .substitutionsPanel, .substitutionOptions, .transformations, .speech, .lookup, .learn, .format, .font, .textSize, .textColor, .textStylePasteboard, .text, .writingDirection, .alignment, .toolbar, .sidebar, .fullscreen, .minimizeAndZoom, .bringAllToFront, .root] + exts
    }
}

#endif
