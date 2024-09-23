// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "SwiftyNifti",
  platforms: [
    .iOS(.v12),
    .macOS(.v10_13),
    .visionOS(.v1),
    .macCatalyst(.v13),
    .tvOS(.v12),
    .watchOS(.v4)
  ],
  products: [
    .library(name: "SwiftyNifti", targets: ["SwiftyNifti"])
  ],
  targets: [
    .target(
      name: "SwiftyNifti"
    ),
    .testTarget(
      name: "SwiftyNiftiTests",
      dependencies: ["SwiftyNifti"],
      resources: [.process("Resources")]
    )
  ],
  swiftLanguageModes: [.v6]
)
