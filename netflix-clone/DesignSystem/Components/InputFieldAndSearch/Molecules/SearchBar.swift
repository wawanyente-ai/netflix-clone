//
//  SearchBar.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//

import SwiftUI

/// Netflix-style search bar backed by a real `TextField`.
///
/// Visual state (centered placeholder → left-aligned cursor → filled text)
/// is derived automatically from `text` and focus, so there's no separate
/// state enum to keep in sync with what the user actually typed.
///
/// ```swift
/// @State private var query = ""
/// SearchBar(text: $query)
/// ```
struct SearchBar: View {

    // MARK: Properties

    @Binding var text: String
    var placeholder: String = "Search"

    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled

    // MARK: Initialization

    init(text: Binding<String>, placeholder: String = "Search") {
        self._text = text
        self.placeholder = placeholder
    }

    // MARK: Body

    var body: some View {
        HStack(spacing: Metrics.spacing) {
            searchIcon

            field

            if !isIdle {
                Spacer(minLength: 0)
                clearButton
            }
        }
        .padding(.horizontal, Metrics.horizontalPadding)
        .padding(.vertical, Metrics.verticalPadding)
        .frame(height: Metrics.height)
        .frame(maxWidth: .infinity, alignment: isIdle ? .center : .leading)
        .background(Color.Neutral.greyDark2)
        .cornerRadius(Metrics.cornerRadius)
        .opacity(isEnabled ? 1 : 0.5)
        .contentShape(Rectangle())
        .onTapGesture { if isEnabled { isFocused = true } }
    }
}

// MARK: - Field

private extension SearchBar {
    /// Idle = nothing typed and not focused — matches the Figma "Default"
    /// state (centered placeholder, no clear icon).
    var isIdle: Bool { text.isEmpty && !isFocused }

    var field: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.Typography.Light.label3)
                    .foregroundStyle(Color.Semantic.textTertiary)
            }
            TextField("", text: $text)
                .focused($isFocused)
                .font(.Typography.Light.label3)
                .foregroundStyle(Color.Neutral.greyLight3)
                .tint(Color.System.blue)
                .autocorrectionDisabled()
                .disabled(!isEnabled)
        }
    }
}

// MARK: - Icons
// Composed from Atoms/TemplateIcon.swift and Atoms/ClearButton.swift.

private extension SearchBar {
    var searchIcon: some View {
        TemplateIcon(image: Image.Icon.search, size: Metrics.iconSize, tint: Color.Semantic.textTertiary)
    }

    /// Clears the text if there is any; otherwise resigns focus — mirrors
    /// the "X" behavior in the Figma spec across all three non-default states.
    var clearButton: some View {
        ClearButton {
            if text.isEmpty {
                isFocused = false
            } else {
                text = ""
            }
        }
    }
}

// MARK: - Metrics

private extension SearchBar {
    enum Metrics {
        static let height: CGFloat = 28
        static let iconSize: CGFloat = 16
        static let spacing: CGFloat = 8
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 4
        static let cornerRadius: CGFloat = 4
    }
}

// MARK: - Preview

#Preview("SearchBar") {
    struct PreviewHost: View {
        @State private var empty = ""
        @State private var filled = "selling sunset"

        var body: some View {
            VStack(spacing: 12) {
                SearchBar(text: $empty)   // tap to see Default → Active
                SearchBar(text: $filled)  // tap to see Inactive-Input → Active-Input
            }
            .padding()
            .frame(width: 334)
            .background(Color.Neutral.black)
        }
    }
    return PreviewHost()
}
