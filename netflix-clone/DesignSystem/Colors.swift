//
//  Colors.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 22/08/26.
//

import SwiftUI

extension Color {
    enum Primary {
        static let redLight1 = Color("RedLight1")
        static let red = Color("Red")
        static let redDark1 = Color("RedDark1")
    }

    enum Neutral {
        static let grey = Color("Grey")
        static let greyDark1 = Color("GreyDark1")
        static let greyDark2 = Color("GreyDark2")
        static let greyDark3 = Color("GreyDark3")

        static let black = Color("Black")

        static let white = Color("White")
        static let greyLight3 = Color("GreyLight3")
        static let greyLight2 = Color("GreyLight2")
        static let greyLight1 = Color("GreyLight1")
    }

    enum System {
        static let red = Color("SystemRed")
        static let blue = Color("SystemBlue")
    }

    enum Semantic {
        static let background = Color.Neutral.black
        static let backgroundSecondary = Color.Neutral.greyDark3

        static let textPrimary = Color.Neutral.white
        static let textSecondary = Color.Neutral.greyLight1
        static let textTertiary = Color.Neutral.grey

        static let brand = Color.Primary.red
        static let brandPressed = Color.Primary.redDark1

        static let error = Color.System.red
        static let info = Color.System.blue
    }
}
