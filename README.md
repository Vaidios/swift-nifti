# SwiftyNifti
[![SPM compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)

A Swift library for reading and manipulating NIfTI (Neuroimaging Informatics Technology Initiative) files. This package provides native Swift support for medical imaging data formats commonly used in neuroscience and medical imaging.

## Features

### Core Functionality
- [x] **NIfTI v1 File Reading** - Parse and read NIfTI v1 (.nii) files
- [x] **Header Parsing** - Extract and access all NIfTI header information
- [x] **Volume Data Access** - Read voxel data from 3D volumes
- [x] **Multiple Data Types** - Support for various data formats (UInt8, UInt16, UInt32, Float32)
- [x] **Endianness Detection** - Automatic byte order detection and handling
- [x] **Plane Extraction** - Extract 2D planes (axial, coronal, sagittal) from 3D volumes

### Data Types Support
- [x] **UInt8** - 8-bit unsigned integers
- [x] **UInt16** - 16-bit unsigned integers  
- [x] **UInt32** - 32-bit unsigned integers
- [x] **Float32** - 32-bit floating point numbers
- [ ] **Int8** - 8-bit signed integers
- [ ] **Int16** - 16-bit signed integers
- [ ] **Int32** - 32-bit signed integers
- [ ] **Int64** - 64-bit signed integers
- [ ] **UInt64** - 64-bit unsigned integers
- [ ] **Float64** - 64-bit floating point numbers
- [ ] **Float128** - 128-bit floating point numbers
- [ ] **Complex64** - 64-bit complex numbers
- [ ] **Complex128** - 128-bit complex numbers
- [ ] **Complex256** - 256-bit complex numbers
- [ ] **RGB24** - 24-bit RGB color data
- [ ] **RGBA32** - 32-bit RGBA color data

### Header Information Access
- [x] **Basic Dimensions** - nx, ny, nz, nt, nu, nv, nw
- [x] **Data Type Information** - datatype, bitpix, bytes per voxel
- [x] **Spatial Information** - pixdim, voxel dimensions
- [x] **Intent Information** - intent_code, intent_p1, intent_p2, intent_p3, intent_name
- [x] **Scaling Information** - scl_slope, scl_inter
- [x] **Calibration** - cal_max, cal_min
- [x] **Slice Information** - slice_start, slice_end, slice_code, slice_duration
- [x] **Units Information** - xyzt_units
- [x] **Transform Information** - qform_code, sform_code, quaternions, srow matrices
- [x] **Metadata** - descript, aux_file, magic string
- [x] **Global Min/Max** - glmin, glmax

### Volume Operations
- [x] **3D Volume Creation** - Create volume objects from voxel data
- [x] **Plane Extraction** - Extract 2D planes in all orientations
- [x] **Volume Statistics** - Basic volume information access
- [ ] **Volume Cropping** - Crop volumes to specific regions
- [ ] **Volume Resampling** - Resample volumes to different resolutions
- [ ] **Volume Concatenation** - Combine multiple volumes
- [ ] **Volume Splitting** - Split volumes along dimensions
- [ ] **Volume Rotation** - Rotate volumes around axes
- [ ] **Volume Flipping** - Flip volumes along axes

### Data Processing
- [x] **Voxel Access** - Individual voxel value access
- [x] **Pixel Data Conversion** - Convert voxels to RGB pixel data
- [ ] **Data Normalization** - Normalize voxel values to different ranges
- [ ] **Data Filtering** - Apply filters to volume data
- [ ] **Data Interpolation** - Interpolate between voxel values
- [ ] **Data Smoothing** - Apply smoothing operations
- [ ] **Data Thresholding** - Apply threshold operations
- [ ] **Data Masking** - Apply masks to volume data

### File Operations
- [x] **File Reading** - Read NIfTI files from URLs
- [x] **Header-Only Reading** - Read only header information
- [x] **Volume-Only Reading** - Read only volume data
- [ ] **File Writing** - Write NIfTI files
- [ ] **File Validation** - Validate NIfTI file integrity
- [ ] **File Compression** - Support for compressed NIfTI files (.nii.gz)
- [ ] **Streaming Support** - Read large files without loading entire file into memory
- [ ] **Memory-Mapped Files** - Efficient memory usage for large files

### Coordinate Systems
- [x] **Voxel Coordinates** - Access data by voxel indices
- [x] **Physical Coordinates** - Basic physical coordinate support via transforms
- [ ] **World Coordinates** - Full world coordinate system support
- [ ] **Coordinate Transformations** - Convert between coordinate systems
- [ ] **Affine Transformations** - Apply affine transformations
- [ ] **Non-linear Transformations** - Support for non-linear warping

### Error Handling
- [x] **Basic Error Types** - Invalid dimensions, header size, data format
- [ ] **Comprehensive Error Handling** - Detailed error messages and recovery
- [ ] **Validation Errors** - File format validation errors
- [ ] **Memory Errors** - Out of memory handling
- [ ] **I/O Errors** - File reading/writing errors

### Performance & Optimization
- [x] **Efficient Binary Reading** - Optimized binary data parsing
- [ ] **Memory Optimization** - Efficient memory usage for large volumes
- [ ] **Parallel Processing** - Multi-threaded operations for large datasets
- [ ] **Lazy Loading** - Load data on-demand
- [ ] **Caching** - Cache frequently accessed data

### Utilities & Extensions
- [x] **Data Extensions** - Swift Data extensions for binary reading
- [x] **FileHandle Extensions** - FileHandle extensions for NIfTI operations
- [ ] **Image Export** - Export volumes as images (PNG, JPEG, TIFF)
- [ ] **Data Export** - Export to other formats (CSV, JSON, etc.)
- [ ] **Metadata Export** - Export header information
- [ ] **Volume Visualization** - Basic volume visualization utilities

### Documentation & Examples
- [x] **Basic Usage** - Simple examples in README
- [ ] **Comprehensive Documentation** - Full API documentation
- [ ] **Code Examples** - Extensive usage examples
- [ ] **Tutorials** - Step-by-step tutorials
- [ ] **Best Practices** - Performance and usage guidelines

### Testing
- [x] **Basic Parsing Tests** - Test file parsing functionality
- [x] **Plane Extraction Tests** - Test 2D plane extraction
- [x] **Binary Reader Tests** - Test binary data reading
- [ ] **Comprehensive Test Suite** - Full test coverage for all functionality
- [ ] **Performance Tests** - Test performance with large files
- [ ] **Error Handling Tests** - Test error conditions
- [ ] **Integration Tests** - Test with real NIfTI files

## Integration

#### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `SwiftyNifti` by adding the proper description to your `Package.swift` file:

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
            name: "YOUR_TARGET", dependencies: [.product(name: "SwiftyNifti", package: "swift-nifti")]
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
```

## Requirements

- iOS 12.0+
- macOS 10.13+
- visionOS 1.0+
- tvOS 12.0+
- watchOS 4.0+

## License

This project is licensed under the MIT License - see the LICENSE file for details.
