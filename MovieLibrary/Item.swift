//
//  Item.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
