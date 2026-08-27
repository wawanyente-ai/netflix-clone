//
//  PlayerView.swift
//  netflix-clone
//

import SwiftUI
import AVKit

/// Custom AVPlayer wrapper that hides default system controls.
/// Uses UIViewRepresentable to render AVPlayerLayer without playback controls.
/// This avoids the "double player" issue with SwiftUI's VideoPlayer.
struct PlayerView: UIViewRepresentable {

    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }
}

// MARK: - UIView Wrapper

class PlayerUIView: UIView {

    override static var layerClass: AnyClass { AVPlayerLayer.self } // ← use AVPlayerLayer

    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer } // ← access layer directly

    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspect // ← ubah video gravity (aspect / resizeAspect / resizeAspectFill)
        playerLayer.backgroundColor = UIColor.black.cgColor // ← ubah warna background player
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // ← nggak pakai storyboard
    }
}
