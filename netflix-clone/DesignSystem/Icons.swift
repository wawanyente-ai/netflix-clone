//
//  Icons.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 23/08/26.
//

import SwiftUI

extension Image {

    // MARK: - Brand

    enum Brand {
        static let logoLarge = Image("NetflixLogoLarge")
        static let logoSingleBadge = Image("NetflixLogoSingleBadge")
        static let logoSmall = Image("NetflixLogoSmall")
        static let wordmark = Image("NetflixWordmark")
    }

    // MARK: - Global Icons

    enum Icon {
        static let add = Image("Add")
        static let brightness = Image("Brightness")
        static let check = Image("Check")
        static let close = Image("Close")
        static let downloadAction = Image("DownloadAction")
        static let downloadNavigation = Image("DownloadNavigation")
        static let error = Image("Error")
        static let home = Image("Home")
        static let info = Image("Info")
        static let like = Image("Like")
        static let lockClosed = Image("LockClosed")
        static let lockOpen = Image("LockOpen")
        static let mirror = Image("Mirror")
        static let pause = Image("Pause")
        static let play = Image("Play")
        static let playStacked = Image("PlayStacked")
        static let search = Image("Search")
        static let share = Image("Share")
        static let skipBackward = Image("SkipBackward")
        static let skipForward = Image("SkipForward")
        static let smile = Image("Smile")
        static let speed = Image("Speed")
        static let subtitles = Image("Subtitles")
        static let user = Image("User")
    }

    // MARK: - User Variants

    enum UserVariant {
        static let blue = Image("UserBlue")
        static let pink = Image("UserPink")
        static let turquoise = Image("UserTurquoise")
        static let turquoise1 = Image("UserTurquoise1")
    }
}
