// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyNifti",

    products: [
        .library(name: "SwiftyNifti", targets: ["SwiftyNifti"])
    ],
    targets: [
        .target(
            name: "SwiftyNifti",
            dependencies: ["SwiftyNiftiCore"]),
        .target(name: "SwiftyNiftiCore"),
        .testTarget(
            name: "SwiftyNiftiTests",
            dependencies: ["SwiftyNifti"]),
    ]
)
