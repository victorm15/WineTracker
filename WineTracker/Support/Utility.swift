import SwiftUI

/// Filled accent-colour button with rounded corners.
struct AccountButton: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.background(Color.accentColor)
			.foregroundStyle(.white)
			.clipShape(RoundedRectangle(cornerRadius: 15))
			.opacity(configuration.isPressed ? 0.85 : 1)
			.scaleEffect(configuration.isPressed ? 0.98 : 1)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}

/// Shrinks a photo so its longest side is at most `maxDimension` pixels and re-encodes it as JPEG.
/// Returns nil if the data isn't an image.
nonisolated func compressedPhotoData(_ data: Data, maxDimension: CGFloat = 1200) -> Data? {
	guard let image = UIImage(data: data) else { return nil }
	let scale = min(1, maxDimension / max(image.size.width, image.size.height))
	let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
	let format = UIGraphicsImageRendererFormat()
	format.scale = 1
	let resized = UIGraphicsImageRenderer(size: size, format: format).image { _ in
		image.draw(in: CGRect(origin: .zero, size: size))
	}
	return resized.jpegData(compressionQuality: 0.8)
}
