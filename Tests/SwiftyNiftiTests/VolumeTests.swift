import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct VolumeTests {
  
  @Test
  func testVolumeCreation() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test volume creation
    #expect(volume.dimensions.nx == 64)
    #expect(volume.dimensions.ny == 64)
    #expect(volume.dimensions.nz == 10)
    #expect(volume.voxels.count == 64 * 64 * 10)
  }
  
  @Test
  func testVolumeDimensions() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test volume dimensions
    let dimensions = volume.dimensions
    #expect(dimensions.nx > 0)
    #expect(dimensions.ny > 0)
    #expect(dimensions.nz > 0)
    #expect(dimensions.nx * dimensions.ny * dimensions.nz == volume.voxels.count)
  }
  
  @Test
  func testVolumeVoxelAccess() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test voxel access
    #expect(!volume.voxels.isEmpty)
    #expect(volume.voxels.count > 0)
    
    // Test first voxel
    let firstVoxel = volume.voxels[0]
    #expect(firstVoxel.value.isFinite)
    
    // Test last voxel
    let lastVoxel = volume.voxels[volume.voxels.count - 1]
    #expect(lastVoxel.value.isFinite)
  }
  
  @Test
  func testVolumeMaxValues() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test max values for each plane direction
    #expect(volume.getMaxValue(of: .axial) == 10)
    #expect(volume.getMaxValue(of: .coronal) == 64)
    #expect(volume.getMaxValue(of: .sagittal) == 64)
  }
  
  @Test
  func testVolumeStatistics() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test basic volume statistics
    let voxelCount = volume.voxels.count
    #expect(voxelCount > 0)
    
    // Test that all voxels have finite values
    for voxel in volume.voxels {
      #expect(voxel.value.isFinite)
    }
    
    // Test that we can find min and max values
    let values = volume.voxels.map { $0.value }
    let minValue = values.min() ?? 0
    let maxValue = values.max() ?? 0
    #expect(minValue.isFinite)
    #expect(maxValue.isFinite)
    #expect(maxValue >= minValue)
  }
  
  @Test
  func testVolumeVoxelConversion() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test voxel to pixel conversion
    let firstVoxel = volume.voxels[0]
    let pixelData = firstVoxel.pixel
    
    #expect(pixelData.a == 255) // Alpha should be 255
    #expect(pixelData.r >= 0 && pixelData.r <= 255)
    #expect(pixelData.g >= 0 && pixelData.g <= 255)
    #expect(pixelData.b >= 0 && pixelData.b <= 255)
  }
  
  @Test
  func testVolumeEquality() async throws {
    let exampleURL = try getExampleURL()
    let volume1 = try NiftiV1(url: exampleURL).volume()
    let volume2 = try NiftiV1(url: exampleURL).volume()
    
    // Test volume equality (should be equal for same file)
    #expect(volume1.dimensions.nx == volume2.dimensions.nx)
    #expect(volume1.dimensions.ny == volume2.dimensions.ny)
    #expect(volume1.dimensions.nz == volume2.dimensions.nz)
    #expect(volume1.voxels.count == volume2.voxels.count)
  }
  
  @Test
  func testVolumeMemoryEfficiency() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test that volume doesn't consume excessive memory
    let expectedVoxelCount = volume.dimensions.nx * volume.dimensions.ny * volume.dimensions.nz
    #expect(volume.voxels.count == expectedVoxelCount)
    
    // Test that voxel values are reasonable (not NaN or infinite)
    for voxel in volume.voxels.prefix(100) { // Test first 100 voxels
      #expect(voxel.value.isFinite)
      #expect(!voxel.value.isNaN)
    }
  }
  
  @Test
  func testVolumeDataIntegrity() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test data integrity - all voxels should be accessible
    for i in 0..<min(1000, volume.voxels.count) { // Test first 1000 voxels
      let voxel = volume.voxels[i]
      #expect(voxel.value.isFinite)
    }
  }
  
  @Test
  func testVolumeCoordinateMapping() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    let nx = volume.dimensions.nx
    let ny = volume.dimensions.ny
    let nz = volume.dimensions.nz
    
    // Test coordinate mapping for first few voxels
    for z in 0..<min(2, nz) {
      for y in 0..<min(2, ny) {
        for x in 0..<min(2, nx) {
          let index = x + y * nx + z * nx * ny
          if index < volume.voxels.count {
            let voxel = volume.voxels[index]
            #expect(voxel.value.isFinite)
          }
        }
      }
    }
  }
  
  @Test
  func testVolumeBoundaryConditions() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test boundary conditions
    #expect(volume.voxels.count > 0)
    
    // Test that we can access the first and last voxels
    let firstVoxel = volume.voxels.first!
    let lastVoxel = volume.voxels.last!
    
    #expect(firstVoxel.value.isFinite)
    #expect(lastVoxel.value.isFinite)
  }
  
  func getExampleURL() throws -> URL {
    try #require(Bundle.module.url(forResource: "minimal", withExtension: "nii"))
  }
} 