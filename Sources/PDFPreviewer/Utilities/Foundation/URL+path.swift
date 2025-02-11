//
//  URL+path.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/9/19.
//

import Foundation

extension URL {
    var versionPath: String {
        if #available(iOS 16.0, macOS 16.0, *) {
            self.path(percentEncoded: false)
        } else {
            self.path
        }
    }
}
