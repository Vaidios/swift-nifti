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
    // Test extracting an axial plane (xy plane at z = 2)

    let expectedAxialPlane: [UInt8] = [32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47]
    
    let expectedVoxels = expectedAxialPlane.map { Voxel(value: $0) }

    let plane = try #require(volume.extractPlane(plane: .axial, sliceIndex: 2))
    
    #expect(plane.data == expectedVoxels)
  }
  
  @Test
  func testCoronalPlane() throws {
    let dimensions = VolumeDimensions(nx: 4, ny: 4, nz: 4)
    let volume = NiftiV1Volume(dimensions: dimensions, voxels: voxels)
    // Test extracting an axial plane (xy plane at z = 2)

    let expectedAxialPlane: [UInt8] = [4, 5, 6, 7, 20, 21, 22, 23, 36, 37, 38, 39, 52, 53, 54, 55]
    let expectedVoxels = expectedAxialPlane.map { Voxel(value: $0) }
    
    let plane = try #require(volume.extractPlane(plane: .coronal, sliceIndex: 2))
    
    #expect(plane.data == expectedVoxels)
  }
  
  @Test
  func testSagittalPlane() throws {
    let dimensions = VolumeDimensions(nx: 4, ny: 4, nz: 4)
    let volume = NiftiV1Volume(dimensions: dimensions, voxels: voxels)
    // Test extracting an axial plane (xy plane at z = 2)

    let expectedAxialPlane: [UInt8] = [2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62]
    let expectedVoxels = expectedAxialPlane.map { Voxel(value: $0) }

    let plane = try #require(volume.extractPlane(plane: .sagittal, sliceIndex: 2))
    
    #expect(plane.data == expectedVoxels)
    
  }
}
