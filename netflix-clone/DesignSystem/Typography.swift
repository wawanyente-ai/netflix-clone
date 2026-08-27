//
//  Typography.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 23/08/26.
//


import SwiftUI

extension Font {

    enum Typography {

        // MARK: - Light

        enum Light {
            static let caption2 = Font.custom(
                "NetflixSans-Light",
                size: 10
            )

            static let caption1 = Font.custom(
                "NetflixSans-Light",
                size: 12
            )

            static let label3 = Font.custom(
                "NetflixSans-Light",
                size: 14
            )

            static let label2 = Font.custom(
                "NetflixSans-Light",
                size: 16
            )

            static let label1 = Font.custom(
                "NetflixSans-Light",
                size: 18
            )

            static let header1 = Font.custom(
                "NetflixSans-Light",
                size: 32
            )
        }

        // MARK: - Medium

        enum Medium {
            static let caption2 = Font.custom(
                "NetflixSans-Medium",
                size: 10
            )

            static let caption1 = Font.custom(
                "NetflixSans-Medium",
                size: 12
            )

            static let label3 = Font.custom(
                "NetflixSans-Medium",
                size: 14
            )

            static let label2 = Font.custom(
                "NetflixSans-Medium",
                size: 16
            )

            static let label1 = Font.custom(
                "NetflixSans-Medium",
                size: 18
            )

            static let header1 = Font.custom(
                "NetflixSans-Medium",
                size: 32
            )
        }

        // MARK: - Bold

        enum Bold {
            static let caption2 = Font.custom(
                "NetflixSans-Bold",
                size: 10
            )

            static let caption1 = Font.custom(
                "NetflixSans-Bold",
                size: 12
            )

            static let label3 = Font.custom(
                "NetflixSans-Bold",
                size: 14
            )

            static let label2 = Font.custom(
                "NetflixSans-Bold",
                size: 16
            )

            static let label1 = Font.custom(
                "NetflixSans-Bold",
                size: 18
            )

            static let header1 = Font.custom(
                "NetflixSans-Bold",
                size: 32
            )
        }
    }
}
