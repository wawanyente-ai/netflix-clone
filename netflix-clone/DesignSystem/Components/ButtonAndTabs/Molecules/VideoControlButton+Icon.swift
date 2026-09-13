//
//  VideoControlButton+Icon.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Icon

extension VideoControlButton {

    var icon: Image {
        switch variant {
        case .play:
            Image.Icon.play

        case .pause:
            Image.Icon.pause

        case .mirror:
            Image.Icon.mirror

        case .close:
            Image.Icon.close

        case .skipForward:
            Image.Icon.skipForward

        case .skipBackward:
            Image.Icon.skipBackward
        }
    }
}