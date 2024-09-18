// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "SwiftyNifti",
    products: [
        .library(name: "SwiftyNifti", targets: ["SwiftyNifti"])
    ],
    targets: [
        .target(
            name: "SwiftyNifti"
        ),
        .testTarget(
            name: "SwiftyNiftiTests",
            dependencies: ["SwiftyNifti"]
        )
    ]
)
