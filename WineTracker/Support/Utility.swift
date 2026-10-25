import SwiftUI



struct AccountButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct GreenButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.darkGreen)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
func isValidEmail(email: String) -> Bool {

    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)

}
/// A password field with a show/hide button, for use in forms.
/// Like `AuthPasswordField`, it never swaps the SecureField out: that would lose focus, and iOS
/// clears a secure field when it's typed into again. Revealing hides it and draws the text on top.
struct SecureInputView: View {
    @Binding private var text: String
    @State private var isRevealed = false
    @FocusState private var isFocused: Bool
    private var title: String

    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }

    var body: some View {
        HStack {
            SecureField(title, text: $text)
                .focused($isFocused)
                .opacity(isRevealed ? 0 : 1)
                .overlay(alignment: .leading) {
                    if isRevealed {
                        Text(text.isEmpty ? title : text)
                            .foregroundStyle(text.isEmpty ? Color.secondary : Color.primary)
                            .lineLimit(1)
                            .truncationMode(.head)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture { isFocused = true }
                            .accessibilityHidden(true)
                    }
                }
            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundStyle(Color.secondary)
            }
            .buttonStyle(.borderless)
            .tint(.secondary)
            .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
        }
    }
}

func isValidField(text:String) -> Bool {
    text.count >= 2
}

let minimumPasswordLength = 8

func isValidPassword(_ password: String) -> Bool {
    password.count >= minimumPasswordLength
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
