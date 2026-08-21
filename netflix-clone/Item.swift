//
//  Item.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 21/08/26.
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
