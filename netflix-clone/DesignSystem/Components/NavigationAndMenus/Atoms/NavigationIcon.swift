//
//  NavigationIcon.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// **Atom** — a nav icon + micro-label pair, tinted by active state.
///
/// This is the single visual unit repeated across every tab, both in the
/// static "Navigation Button States" reference and inside the live
/// `NavigationBar` molecule.
///
/// > Reuses `TemplateIcon` (see `Input_And_Search/Atoms`) for the icon
/// > rendering pattern. That atom is generic enough it's worth promoting
/// > to a shared `Components/Shared/Atoms/` location now that a second
/// > group depends on it, rather than duplicating it here.
struct NavigationIcon: View {
    let icon: Image
    let title: String
    var isActive: Bool

    var body: some View {
        VStack(spacing: Metrics.spacing) {
            TemplateIcon(image: icon, size: Metrics.iconSize, tint: tint)

            Text(title)
                // NOTE: the Figma spec calls for an 8pt label; the DS's
                // smallest defined role is `caption2` (10pt) — there is no
                // 8pt role to reach for. Using `caption2` here as the
                // closest catalog match rather than inlining a raw
                // `.font(.system(size: 8))`, which the DS conventions
                // explicitly forbid outside Typography.swift. If pixel
                // parity matters, ask design/DS-owner to add a `caption3`
                // (8pt) role to Typography.swift.
                .font(.Typography.Light.caption2)
                .foregroundStyle(tint)
        }
        .frame(width: Metrics.width, height: Metrics.height)
    }
}

// MARK: - Tint

private extension NavigationIcon {
    /// Figma's active label color (`#D9D9D9`) isn't a cataloged token —
    /// it sits between `greyLight2` and `greyLight3`. Using a single tint
    /// for both icon and label (`greyLight2`, matching the active icon)
    /// keeps the pair visually consistent instead of introducing an
    /// uncataloged raw color.
    var tint: Color {
        isActive ? Color.Neutral.greyLight2 : Color.Neutral.grey
    }
}

// MARK: - Metrics

private extension NavigationIcon {
    enum Metrics {
        static let width: CGFloat = 75
        static let height: CGFloat = 36
        static let iconSize: CGFloat = 24
        static let spacing: CGFloat = 2
    }
}

// MARK: - Preview

#Preview("NavigationIcon — Inactive vs Active") {
    HStack(spacing: 16) {
        NavigationIcon(icon: Image.Icon.home, title: "Home", isActive: false)
        NavigationIcon(icon: Image.Icon.home, title: "Home", isActive: true)
    }
    .padding()
    .background(Color.Neutral.black)
}