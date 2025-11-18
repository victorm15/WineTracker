import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AccentColor" asset catalog color resource.
    static let accent = DeveloperToolsSupport.ColorResource(name: "AccentColor", bundle: resourceBundle)

    /// The "DarkGreen" asset catalog color resource.
    static let darkGreen = DeveloperToolsSupport.ColorResource(name: "DarkGreen", bundle: resourceBundle)

    /// The "LighterGray" asset catalog color resource.
    static let lighterGray = DeveloperToolsSupport.ColorResource(name: "LighterGray", bundle: resourceBundle)

    /// The "VeryLightGray" asset catalog color resource.
    static let veryLightGray = DeveloperToolsSupport.ColorResource(name: "VeryLightGray", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "Filter" asset catalog image resource.
    static let filter = DeveloperToolsSupport.ImageResource(name: "Filter", bundle: resourceBundle)

    /// The "Image" asset catalog image resource.
    static let image = DeveloperToolsSupport.ImageResource(name: "Image", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "AccentColor" asset catalog color.
    static var accent: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "DarkGreen" asset catalog color.
    static var darkGreen: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .darkGreen)
#else
        .init()
#endif
    }

    /// The "LighterGray" asset catalog color.
    static var lighterGray: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .lighterGray)
#else
        .init()
#endif
    }

    /// The "VeryLightGray" asset catalog color.
    static var veryLightGray: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .veryLightGray)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "AccentColor" asset catalog color.
    static var accent: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "DarkGreen" asset catalog color.
    static var darkGreen: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .darkGreen)
#else
        .init()
#endif
    }

    /// The "LighterGray" asset catalog color.
    static var lighterGray: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .lighterGray)
#else
        .init()
#endif
    }

    /// The "VeryLightGray" asset catalog color.
    static var veryLightGray: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .veryLightGray)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "DarkGreen" asset catalog color.
    static var darkGreen: SwiftUI.Color { .init(.darkGreen) }

    /// The "LighterGray" asset catalog color.
    static var lighterGray: SwiftUI.Color { .init(.lighterGray) }

    /// The "VeryLightGray" asset catalog color.
    static var veryLightGray: SwiftUI.Color { .init(.veryLightGray) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "DarkGreen" asset catalog color.
    static var darkGreen: SwiftUI.Color { .init(.darkGreen) }

    /// The "LighterGray" asset catalog color.
    static var lighterGray: SwiftUI.Color { .init(.lighterGray) }

    /// The "VeryLightGray" asset catalog color.
    static var veryLightGray: SwiftUI.Color { .init(.veryLightGray) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "Filter" asset catalog image.
    static var filter: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .filter)
#else
        .init()
#endif
    }

    /// The "Image" asset catalog image.
    static var image: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .image)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "Filter" asset catalog image.
    static var filter: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .filter)
#else
        .init()
#endif
    }

    /// The "Image" asset catalog image.
    static var image: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .image)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

