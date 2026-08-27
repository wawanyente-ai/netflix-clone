//
//  VideoTabButton.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 24/08/26.
//


import SwiftUI

struct VideoTabButton: View {

    // MARK: - Properties

    private let title: String
    private let isSelected: Bool
    private let action: () -> Void

    // MARK: - Initialization

    init(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(
                        isSelected
                            ? Color.Neutral.white
                            : Color.Neutral.greyDark1
                    )

                Rectangle()
                    .fill(
                        isSelected
                            ? Color.Primary.red
                            : Color.clear
                    )
                    .frame(height: 4)
            }
        }
        .buttonStyle(.plain)
    }
}