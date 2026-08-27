//
//  VideoPlayerTopBar.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// The top chrome row shown over the video player: cast/mirror button,
/// centered title, close button.
///
/// Composed entirely from the existing `VideoControlButton` molecule
/// (`Button_And_Tabs/Molecules`). Used by both the landscape and portrait
/// video player templates.
///
/// ```swift
/// VideoPlayerTopBar(title: "S0:E0 \"Episode Name\"", onCastTap: {}, onCloseTap: {})
/// ```
struct VideoPlayerTopBar: View {
    let title: String
    var onCastTap: () -> Void
    var onCloseTap: () -> Void

    var body: some View {
        HStack {
            VideoControlButton(variant: .mirror, action: onCastTap)
            Spacer()
            Text(title)
                .font(.Typography.Medium.label3)
                .foregroundStyle(Color.Neutral.white)
                .lineLimit(1)
            Spacer()
            VideoControlButton(variant: .close, action: onCloseTap)
        }
    }
}

#Preview {
    VideoPlayerTopBar(title: "S0:E0 \"Episode Name\"", onCastTap: {}, onCloseTap: {})
        .padding()
        .background(Color.Neutral.black)
}