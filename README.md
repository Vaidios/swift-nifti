# SwiftyNifti
[![SPM compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

A Swift library for reading and writing NIfTI (Neuroimaging Informatics Technology Initiative) files. This package provides native Swift support for medical imaging data formats commonly used in neuroscience and medical imaging.

## Overview

SwiftyNifti provides a Swift-native API that mirrors the functionality of the official NIfTI C API. It supports reading and writing NIfTI-1 (.nii) files with comprehensive header parsing, volume data access, and 2D plane extraction.

## Key Features

- **Complete NIfTI-1 Support**: Read and write uncompressed NIfTI-1 files
- **Header Parsing**: Access all NIfTI header fields and metadata
- **Volume Data**: Read 3D volume data with automatic endianness detection
- **Plane Extraction**: Extract 2D planes (axial, coronal, sagittal) from 3D volumes
- **Data Types**: Support for UInt8, UInt16, UInt32, and Float32 data types
- **File Writing**: Write NIfTI files with custom headers and volume data
- **Header Dumping**: Human-readable header information and ASCII export

## NIfTI C API Compatibility

This library aims to provide feature parity with the official NIfTI C API. Below is a detailed comparison:

| C API Functionality | Swift API Status | Implementation |
|---------------------|------------------|----------------|
| **Read NIfTI header** | ✅ Implemented | `NiftiV1.header()` |
| **Read NIfTI image data** | ✅ Implemented | `NiftiV1.volume()`, `NiftiV1.readData()` |
| **Write NIfTI file** | ✅ Implemented | `NiftiV1.write(header:volume:to:)` |
| **Validate NIfTI file** | ✅ Implemented | `NiftiV1.isNiftiFile(url:)` |
| **Dump header info** | ✅ Implemented | `NiftiV1.dumpHeaderInfo()` |
| **Header to ASCII** | ✅ Implemented | `NiftiV1.headerToAscii()` |
| **Get file info** | ✅ Implemented | `NiftiV1.getFileInfo()` |
| **Free image memory** | ✅ N/A (Swift ARC) | Managed by Swift ARC |
| **Convert header formats** | ❌ Not implemented | |
| **Compressed files (.nii.gz)** | ❌ Not implemented | |
| **Streaming/partial read** | ❌ Not implemented | |
| **Advanced data types** | ⚠️ Partial | Basic types only |
| **File format conversion** | ❌ Not implemented | |
| **Coordinate transforms** | ❌ Not implemented | |

### Data Type Support

- **Fully Supported**: UInt8, UInt16, UInt32, Float32
- **Partially Supported**: Int8, Int16, Int32, Int64, UInt64, Float64, Float128, Complex, RGB, RGBA (headers recognized, limited data parsing)
- **Not Supported**: Full support for all NIfTI-1/2 data types

## Installation

### Swift Package Manager

Add SwiftyNifti to your `Package.swift`:

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

## Basic Usage

```swift
import SwiftyNifti

// Read a NIfTI file
let nifti = try NiftiV1(url: fileURL)

// Access header information
let header = try nifti.header()
print("Dimensions: \(header.dimensions)")
print("Data type: \(header.datatypeString)")

// Access volume data
let volume = try nifti.volume()
print("Number of voxels: \(volume.voxels.count)")

// Extract a 2D plane
let axialPlane = volume.extractPlane(plane: .axial, sliceIndex: 5)
print("Plane dimensions: \(axialPlane?.width) x \(axialPlane?.height)")

// Get detailed header information
let headerInfo = try nifti.dumpHeaderInfo()
print(headerInfo)

// Write a NIfTI file
try NiftiV1.write(header: header, volume: volume, to: outputURL)
```

## Advanced Usage

```swift
// Read only header without loading volume data
let header = try nifti.header()

// Read only volume data
let voxels = try nifti.readData()

// Convert header to ASCII format
let asciiHeader = try nifti.headerToAscii()

// Get file statistics
let fileInfo = try nifti.getFileInfo()
print("File size: \(fileInfo.fileSize) bytes")
print("Total voxels: \(fileInfo.totalVoxels)")

// Access individual header fields
print("X dimension: \(header.nx)")
print("Y dimension: \(header.ny)")
print("Z dimension: \(header.nz)")
print("Pixel spacing X: \(header.dx)")
print("Pixel spacing Y: \(header.dy)")
print("Pixel spacing Z: \(header.dz)")
```

## Requirements

- iOS 12.0+
- macOS 10.13+
- visionOS 1.0+
- tvOS 12.0+
- watchOS 4.0+

## Limitations

- **Compressed files**: Only uncompressed NIfTI-1 (.nii) files are supported
- **Data types**: Limited support for advanced data types (complex, RGB, etc.)
- **Large files**: No streaming support for very large files
- **Format conversion**: No support for Analyze or NIfTI-2 formats
- **Coordinate transforms**: Basic support only

## Contributing

Contributions are welcome! Areas that need work:
- Compressed file support (.nii.gz)
- Full data type support
- Streaming/large file support
- Format conversion utilities
- Performance optimizations

## License

This project is licensed under the MIT License - see the LICENSE file for details.
