# SwiftyNifti
[![SPM compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

A lightweight Swift library for reading [NIfTI](https://nifti.nimh.nih.gov/) `.nii` files. The package parses NIfTI‑1 headers and exposes voxel data so you can easily work with medical imaging volumes directly in Swift.

## Features

- Pure Swift implementation with no external dependencies
- Supports reading NIfTI‑1 headers and volume data
- Convenience APIs to extract axial, coronal and sagittal planes
- Compatible with iOS, macOS, visionOS, tvOS, watchOS and macCatalyst

## Installation

### Swift Package Manager

Add **SwiftyNifti** as a dependency in your `Package.swift`:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/Vaidios/swift-nifti.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "YOUR_TARGET",
            dependencies: [.product(name: "SwiftyNifti", package: "swift-nifti")]
        )
    ]
)
```

## Usage

```swift
import SwiftyNifti

let fileURL = URL(fileURLWithPath: "path/to/file.nii")
let nifti = try NiftiV1(url: fileURL)

let header = try nifti.header()
print("Dimensions: \(header.dimensions)")

let volume = try nifti.volume()
let firstSlice = volume.extractPlane(plane: .axial, sliceIndex: 0)
```

`NiftiV1` currently supports uncompressed NIfTI‑1 files. From the `NiftiV1Volume` object you can access all voxels or extract 2D planes for further processing.

