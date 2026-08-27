//
//  InputField.swift
//  netflix-clone
//
//  Created by tpcahmad5054 on 25/08/26.
//


import SwiftUI

/// Netflix-style text input field backed by a real `TextField`.
///
/// Border/text styling (default → focused → filled → error) is derived
/// from `text`, focus, and an optional `errorMessage`. Pass a non-nil
/// message to switch the field into its error style regardless of focus.
///
/// ```swift
/// @State private var email = ""
/// InputField(text: $email, placeholder: "Enter email")
///
/// InputField(
///     text: $email,
///     placeholder: "Enter email",
///     errorMessage: "Please enter a valid email address"
/// )
/// ```
struct InputField: View {

    // MARK: Properties

    @Binding var text: String
    var placeholder: String
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled

    // MARK: Initialization

    init(text: Binding<String>, placeholder: String, errorMessage: String? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.errorMessage = errorMessage
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.helperSpacing) {
            HStack(spacing: Metrics.iconSpacing) {
                field
                if errorMessage != nil {
                    errorIcon
                }
            }
            .padding(.horizontal, Metrics.horizontalPadding)
            .padding(.vertical, Metrics.verticalPadding)
            .frame(height: Metrics.height)
            .overlay(
                RoundedRectangle(cornerRadius: Metrics.cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )

            if let errorMessage {
                Text(errorMessage)
                    .font(.Typography.Medium.caption2)
                    .foregroundStyle(Color.Semantic.textSecondary)
            }
        }
        .opacity(isEnabled ? 1 : 0.5)
    }
}

// MARK: - Field

private extension InputField {
    var field: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.Typography.Medium.label2)
                    .foregroundStyle(Color.Semantic.textSecondary)
            }
            TextField("", text: $text)
                .focused($isFocused)
                .font(.Typography.Medium.label2)
                .foregroundStyle(textColor)
                .tint(Color.System.blue)
                .autocorrectionDisabled()
                .disabled(!isEnabled)
        }
    }

    var textColor: Color {
        errorMessage != nil ? Color.Semantic.error : Color.Neutral.greyLight2
    }

    var borderColor: Color {
        if errorMessage != nil { return Color.Semantic.error }
        if isFocused { return Color.System.blue }
        return Color.Neutral.greyLight1
    }
}

// MARK: - Icons
// Composed from Atoms/TemplateIcon.swift.

private extension InputField {
    var errorIcon: some View {
        TemplateIcon(image: Image.Icon.error, size: Metrics.errorIconSize, tint: Color.Semantic.error)
    }
}

// MARK: - Metrics

private extension InputField {
    enum Metrics {
        static let height: CGFloat = 52
        static let cornerRadius: CGFloat = 2
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 16
        static let iconSpacing: CGFloat = 8
        static let helperSpacing: CGFloat = 4
        static let errorIconSize: CGFloat = 24
    }
}

// MARK: - Preview

#Preview("InputField") {
    struct PreviewHost: View {
        @State private var empty = ""
        @State private var filled = "ellie@netflix.com"
        @State private var invalid = "ellie@netflix.com"

        var body: some View {
            VStack(spacing: 16) {
                InputField(text: $empty, placeholder: "Enter email")
                InputField(text: $filled, placeholder: "Enter email")
                InputField(
                    text: $invalid,
                    placeholder: "Enter email",
                    errorMessage: "Please enter a valid email address"
                )
            }
            .padding()
            .frame(width: 375)
            .background(Color.Neutral.black)
        }
    }
    return PreviewHost()
}