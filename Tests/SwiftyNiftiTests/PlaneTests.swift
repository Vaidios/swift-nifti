import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct PlaneTests {
  let data: [UInt8] = [
    0, 1, 2, 3,     // First row (x-axis) of first slice (z=0)
    4, 5, 6, 7,     // Second row (y-axis) of first slice
    8, 9, 10, 11,   // Third row of first slice
    12, 13, 14, 15, // Fourth row of first slice (z=0)

    16, 17, 18, 19, // First row of second slice (z=1)
    20, 21, 22, 23, // ...
    24, 25, 26, 27,
    28, 29, 30, 31,

    32, 33, 34, 35, // First row of third slice (z=2)
    36, 37, 38, 39, // ...
    40, 41, 42, 43,
    44, 45, 46, 47,

    48, 49, 50, 51, // First row of fourth slice (z=3)
    52, 53, 54, 55, // ...
    56, 57, 58, 59,
    60, 61, 62, 63
  ]
  var voxels: [Voxel] { data.map { Voxel(value: $0) } }
  
  @Test
  func testAxialPlane() throws {
    let dimensions = VolumeDimensions(nx: 4, ny: 4, nz: 4)
    let volume = NiftiV1Volume(dimensions: dimensions, voxels: voxels)

    let expectedPlane0: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    let expectedPlane1: [UInt8] = [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31]
    let expectedPlane2: [UInt8] = [32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47]
    let expectedPlane3: [UInt8] = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63]

    let plane0 = try #require(volume.extractPlane(plane: .axial, sliceIndex: 0))
    let plane1 = try #require(volume.extractPlane(plane: .axial, sliceIndex: 1))
    let plane2 = try #require(volume.extractPlane(plane: .axial, sliceIndex: 2))
    let plane3 = try #require(volume.extractPlane(plane: .axial, sliceIndex: 3))
    
    #expect(plane0.data == expectedPlane0.map(Voxel.init))
    #expect(plane1.data == expectedPlane1.map(Voxel.init))
    #expect(plane2.data == expectedPlane2.map(Voxel.init))
    #expect(plane3.data == expectedPlane3.map(Voxel.init))
  }
  
  @Test
  func testCoronalPlane() throws {
    let dimensions = VolumeDimensions(nx: 4, ny: 4, nz: 4)
    let volume = NiftiV1Volume(dimensions: dimensions, voxels: voxels)

    let expectedPlane0: [UInt8] = [0, 1, 2, 3, 16, 17, 18, 19, 32, 33, 34, 35, 48, 49, 50, 51]
    let expectedPlane1: [UInt8] = [4, 5, 6, 7, 20, 21, 22, 23, 36, 37, 38, 39, 52, 53, 54, 55]
    let expectedPlane2: [UInt8] = [8, 9, 10, 11, 24, 25, 26, 27, 40, 41, 42, 43, 56, 57, 58, 59]
    let expectedPlane3: [UInt8] = [12, 13, 14, 15, 28, 29, 30, 31, 44, 45, 46, 47, 60, 61, 62, 63]
    
    let plane0 = try #require(volume.extractPlane(plane: .coronal, sliceIndex: 0))
    let plane1 = try #require(volume.extractPlane(plane: .coronal, sliceIndex: 1))
    let plane2 = try #require(volume.extractPlane(plane: .coronal, sliceIndex: 2))
    let plane3 = try #require(volume.extractPlane(plane: .coronal, sliceIndex: 3))
    
    #expect(plane0.data == expectedPlane0.map(Voxel.init))
    #expect(plane1.data == expectedPlane1.map(Voxel.init))
    #expect(plane2.data == expectedPlane2.map(Voxel.init))
    #expect(plane3.data == expectedPlane3.map(Voxel.init))
  }
  
  @Test
  func testSagittalPlane() throws {
    let dimensions = VolumeDimensions(nx: 4, ny: 4, nz: 4)
    let volume = NiftiV1Volume(dimensions: dimensions, voxels: voxels)
    // Test extracting an axial plane (xy plane at z = 2)

    let expectedPlane0: [UInt8] = [0, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60]
    let expectedPlane1: [UInt8] = [1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53, 57, 61]
    let expectedPlane2: [UInt8] = [2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62]
    let expectedPlane3: [UInt8] = [3, 7, 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51, 55, 59, 63]

    let plane0 = try #require(volume.extractPlane(plane: .sagittal, sliceIndex: 0))
    let plane1 = try #require(volume.extractPlane(plane: .sagittal, sliceIndex: 1))
    let plane2 = try #require(volume.extractPlane(plane: .sagittal, sliceIndex: 2))
    let plane3 = try #require(volume.extractPlane(plane: .sagittal, sliceIndex: 3))
    
    #expect(plane0.data == expectedPlane0.map(Voxel.init))
    #expect(plane1.data == expectedPlane1.map(Voxel.init))
    #expect(plane2.data == expectedPlane2.map(Voxel.init))
    #expect(plane3.data == expectedPlane3.map(Voxel.init))
  }
}
