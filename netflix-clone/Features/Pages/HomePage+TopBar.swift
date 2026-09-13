//
//  HomePage+TopBar.swift
//  netflix-clone
//

import SwiftUI

extension HomePage {

    // MARK: - Top Bar (sticky, tappable)

    var topBar: some View {
        HStack(spacing: 16) {
            // ← logo = reset kategori (kembali ke All)
            Button {
                viewModel.selectedContentType = .all // ← reset filter ke All
            } label: {
                Image.Brand.logoSmall
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
            }
            .buttonStyle(.plain)

            // ← tappable: TV Shows
            Button {
                viewModel.selectedContentType = .tvShows // ← filter TV shows
            } label: {
                Text("TV Shows")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(
                        viewModel.selectedContentType == .tvShows
                            ? Color.Semantic.textPrimary // ← aktif: putih
                            : Color.Semantic.textTertiary // ← inactive: abu
                    )
            }

            // ← tappable: Movies
            Button {
                viewModel.selectedContentType = .movies // ← filter movies
            } label: {
                Text("Movies")
                    .font(.Typography.Medium.label3)
                    .foregroundStyle(
                        viewModel.selectedContentType == .movies
                            ? Color.Semantic.textPrimary
                            : Color.Semantic.textTertiary
                    )
            }

            // ← dropdown Categories (menu fungsional: All / TV Shows / Movies)
            Menu {
                categoryOption("All", type: .all)
                Divider()
                categoryOption("TV Shows", type: .tvShows)
                categoryOption("Movies", type: .movies)
            } label: {
                HStack(spacing: 2) {
                    Text("Categories")
                        .font(.Typography.Medium.label3)
                    // ← custom chevron (bukan SF Symbol)
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 4, y: 4))
                        path.addLine(to: CGPoint(x: 8, y: 0))
                    }
                    .stroke(Color.Semantic.textPrimary, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .frame(width: 8, height: 5)
                }
                .foregroundStyle(Color.Semantic.textPrimary)
            }

            Spacer()

            TemplateIcon(image: Image.Icon.mirror, size: 20, tint: Color.Semantic.textPrimary)

            Image.UserVariant.blue
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.Semantic.background)
    }

    // MARK: - Category Option (buat isi dropdown)

    private func categoryOption(_ title: String, type: HomeViewModelCached.ContentType) -> some View {
        Button {
            viewModel.selectedContentType = type // ← set filter dari dropdown
        } label: {
            HStack {
                Text(title)
                Spacer()
                if viewModel.selectedContentType == type {
                    Image.Icon.check // ← centang opsi aktif
                        .renderingMode(.template)
                        .frame(width: 14, height: 14)
                }
            }
        }
    }
}