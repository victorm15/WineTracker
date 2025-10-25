#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"VictorM.coretests";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "DarkGreen" asset catalog color resource.
static NSString * const ACColorNameDarkGreen AC_SWIFT_PRIVATE = @"DarkGreen";

/// The "LighterGray" asset catalog color resource.
static NSString * const ACColorNameLighterGray AC_SWIFT_PRIVATE = @"LighterGray";

/// The "VeryLightGray" asset catalog color resource.
static NSString * const ACColorNameVeryLightGray AC_SWIFT_PRIVATE = @"VeryLightGray";

/// The "Filter" asset catalog image resource.
static NSString * const ACImageNameFilter AC_SWIFT_PRIVATE = @"Filter";

/// The "Image" asset catalog image resource.
static NSString * const ACImageNameImage AC_SWIFT_PRIVATE = @"Image";

#undef AC_SWIFT_PRIVATE
