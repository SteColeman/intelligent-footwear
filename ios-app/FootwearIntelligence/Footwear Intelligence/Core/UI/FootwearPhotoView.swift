import SwiftUI

struct FootwearPhotoView: View {
    let photoUrl: String?
    let size: CGFloat
    let cornerRadius: CGFloat
    let tint: Color
    let iconName: String
    let iconFont: Font
    let progressTint: Color
    let backgroundOpacity: Double
    let strokeOpacity: Double

    init(
        photoUrl: String?,
        size: CGFloat,
        cornerRadius: CGFloat = 22,
        tint: Color = Color(red: 0.90, green: 0.89, blue: 0.81),
        iconName: String = "shoeprints.fill",
        iconFont: Font = .title2,
        progressTint: Color = .secondary,
        backgroundOpacity: Double = 0.35,
        strokeOpacity: Double = 0
    ) {
        self.photoUrl = photoUrl
        self.size = size
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.iconName = iconName
        self.iconFont = iconFont
        self.progressTint = progressTint
        self.backgroundOpacity = backgroundOpacity
        self.strokeOpacity = strokeOpacity
    }

    var body: some View {
        if let photoUrl, let url = URL(string: photoUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
                    .tint(progressTint)
            }
            .frame(width: size, height: size)
            .background(Color.white.opacity(backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(strokeOpacity), lineWidth: strokeOpacity > 0 ? 1 : 0)
            )
        } else {
            WarmIconTile(systemName: iconName, tint: tint, size: size)
        }
    }
}
