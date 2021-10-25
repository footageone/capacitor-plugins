//
//  AssetUploadExtension.swift
//  Plugin
//
//  Created by Daniel Schuba on 29.10.21.
//  Copyright © 2021 Max Lynch. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}
