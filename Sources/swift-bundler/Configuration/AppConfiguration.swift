import Foundation

/// The configuration for an app.
struct AppConfiguration: Codable {
  /// The app's identifier (e.g. `com.example.ExampleApp`).
  var identifier: String
  /// The name of the executable product.
  var product: String
  /// The app's current version.
  var version: String
  // swiftlint:disable:next line_length
  /// The app's category. See [Apple's documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/lsapplicationcategorytype) for more details.
  var category: String?
  /// The minimum macOS version that the app can run on.
  var minimumMacOSVersion: String?
  /// The minimum iOS version that the app can run on.
  var minimumIOSVersion: String?
  /// The path to the app's icon.
  var icon: String?
  /// A dictionary containing extra entries to add to the app's `Info.plist` file.
  ///
  /// String values can contain variable substitutions (see ``ExpressionEvaluator`` for details).
  var plist: [String: PlistValue]?

  enum CodingKeys: String, CodingKey {
    case product
    case version
    case category
    case identifier = "identifier"
    case minimumMacOSVersion = "minimum_macos_version"
    case minimumIOSVersion = "minimum_ios_version"
    case icon
    case plist
  }

  /// Appends the contents of a plist dictionary to the app's Info.plist entries.
  /// - Parameters:
  ///   - dictionary: The plist dictionary to append.
  ///   - excludeHandledKeys: If `true`, entries that are already autogenerated by Swift Bundler at build are excluded.
  /// - Returns: The new configuration.
  func appendingInfoPlistEntries(
    _ dictionary: [String: PlistValue],
    excludeHandledKeys: Bool = false
  ) -> AppConfiguration {
    var filteredDictionary = dictionary
    if excludeHandledKeys {
      let excludedKeys: Set<String> = [
        "CFBundleExecutable",
        "CFBundleIdentifier",
        "CFBundleInfoDictionaryVersion",
        "CFBundleName",
        "CFBundleDisplayName",
        "CFBundlePackageType",
        "CFBundleShortVersionString",
        "CFBundleSignature",
        "CFBundleVersion",
        "LSRequiresIPhoneOS"
      ]

      filteredDictionary = dictionary.filter { key, value in
        return !(excludedKeys.contains(key) || (key == "CFBundleDevelopmentRegion" && value == .string("en")))
      }
    }

    var configuration = self
    configuration.plist = configuration.plist.map { plist in
      var plist = plist
      for (key, value) in filteredDictionary {
        plist[key] = value
      }
      return plist
    } ?? filteredDictionary

    return configuration
  }
}
