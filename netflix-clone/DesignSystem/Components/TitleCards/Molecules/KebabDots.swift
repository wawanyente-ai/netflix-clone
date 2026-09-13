//
//  KebabDots.swift
//  netflix-clone
//

import SwiftUI

// MARK: - Kebab Dots Shape

struct KebabDots: Shape {
    func path(in rect: CGRect) -> Path {
        let dotRadius = rect.width * 0.12
        let spacing = rect.height / 3
        var path = Path()
        for i in 0..<3 {
            let center = CGPoint(x: rect.midX, y: spacing * CGFloat(i + 1) - spacing / 2)
            path.addEllipse(in: CGRect(
                x: center.x - dotRadius,
                y: center.y - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            ))
        }
        return path
    }
}