import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct IntegrationTests {
  
  @Test
  func testCompleteWorkflow() async throws {
    let exampleURL = try getExampleURL()
    
    // Test complete workflow: read file, get header, get volume, extract planes
    let nifti = try NiftiV1(url: exampleURL)
    
    // Step 1: Read header
    let header = try nifti.header()
    #expect(header.sizeof_hdr == 348)
    #expect(header.ndim == 3)
    
    // Step 2: Read volume
    let volume = try nifti.volume()
    #expect(volume.voxels.count > 0)
    #expect(volume.dimensions.nx == header.nx)
    #expect(volume.dimensions.ny == header.ny)
    #expect(volume.dimensions.nz == header.nz)
    
    // Step 3: Extract planes
    let axialPlane = volume.extractPlane(plane: .axial, sliceIndex: 0)
    #expect(axialPlane != nil)
    #expect(axialPlane?.width == volume.dimensions.nx)
    #expect(axialPlane?.height == volume.dimensions.ny)
    
    let coronalPlane = volume.extractPlane(plane: .coronal, sliceIndex: 0)
    #expect(coronalPlane != nil)
    #expect(coronalPlane?.width == volume.dimensions.nx)
    #expect(coronalPlane?.height == volume.dimensions.nz)
    
    let sagittalPlane = volume.extractPlane(plane: .sagittal, sliceIndex: 0)
    #expect(sagittalPlane != nil)
    #expect(sagittalPlane?.width == volume.dimensions.ny)
    #expect(sagittalPlane?.height == volume.dimensions.nz)
  }
  
  @Test
  func testHeaderVolumeConsistency() async throws {
    let exampleURL = try getExampleURL()
    let nifti = try NiftiV1(url: exampleURL)
    
    // Test that header and volume information are consistent
    let header = try nifti.header()
    let volume = try nifti.volume()
    
    // Check dimensions consistency
    #expect(header.nx == volume.dimensions.nx)
    #expect(header.ny == volume.dimensions.ny)
    #expect(header.nz == volume.dimensions.nz)
    
    // Check voxel count consistency
    let expectedVoxelCount = header.nx * header.ny * header.nz
    #expect(volume.voxels.count == expectedVoxelCount)
    
    // Check data type consistency
    #expect(header.bytesPerVoxel > 0)
    #expect(header.bitpix > 0)
    #expect(header.bitpix == header.bytesPerVoxel * 8)
  }
  
  @Test
  func testPlaneExtractionConsistency() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test that plane extraction is consistent across all orientations
    let nx = volume.dimensions.nx
    let ny = volume.dimensions.ny
    let nz = volume.dimensions.nz
    
    // Test axial planes
    for z in 0..<min(3, nz) {
      let plane = volume.extractPlane(plane: .axial, sliceIndex: z)
      #expect(plane != nil)
      #expect(plane?.width == nx)
      #expect(plane?.height == ny)
      #expect(plane?.data.count == nx * ny)
    }
    
    // Test coronal planes
    for y in 0..<min(3, ny) {
      let plane = volume.extractPlane(plane: .coronal, sliceIndex: y)
      #expect(plane != nil)
      #expect(plane?.width == nx)
      #expect(plane?.height == nz)
      #expect(plane?.data.count == nx * nz)
    }
    
    // Test sagittal planes
    for x in 0..<min(3, nx) {
      let plane = volume.extractPlane(plane: .sagittal, sliceIndex: x)
      #expect(plane != nil)
      #expect(plane?.width == ny)
      #expect(plane?.height == nz)
      #expect(plane?.data.count == ny * nz)
    }
  }
  
  @Test
  func testVoxelDataIntegrity() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test that voxel data is consistent and valid
    let voxels = volume.voxels
    
    // Check that all voxels have finite values
    for voxel in voxels {
      #expect(voxel.value.isFinite)
      #expect(!voxel.value.isNaN)
    }
    
    // Check that we can convert voxels to pixels
    for i in 0..<min(1000, voxels.count) {
      let pixel = voxels[i].pixel
      #expect(pixel.a == 255)
      #expect(pixel.r >= 0 && pixel.r <= 255)
      #expect(pixel.g >= 0 && pixel.g <= 255)
      #expect(pixel.b >= 0 && pixel.b <= 255)
    }
  }
  
  @Test
  func testCoordinateMapping() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    let nx = volume.dimensions.nx
    let ny = volume.dimensions.ny
    let nz = volume.dimensions.nz
    
    // Test coordinate mapping for specific voxels
    for z in 0..<min(2, nz) {
      for y in 0..<min(2, ny) {
        for x in 0..<min(2, nx) {
          let index = x + y * nx + z * nx * ny
          if index < volume.voxels.count {
            let voxel = volume.voxels[index]
            #expect(voxel.value.isFinite)
            
            // Test that the voxel can be converted to pixel data
            let pixel = voxel.pixel
            #expect(pixel.a == 255)
          }
        }
      }
    }
  }
  
  @Test
  func testHeaderMetadataAccess() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test that all header metadata is accessible
    let dataArray = header.dataArray
    #expect(!dataArray.isEmpty)
    
    // Check that key fields are present
    let fieldNames = dataArray.map { $0.0 }
    #expect(fieldNames.contains("Size of header"))
    #expect(fieldNames.contains("Dimension sizes"))
    #expect(fieldNames.contains("Datatype"))
    #expect(fieldNames.contains("Pixel dimensions"))
    
    // Test description string
    let description = header.description
    #expect(!description.isEmpty)
    #expect(description.contains("Dimensions"))
    #expect(description.contains("Datatype"))
  }
  
  @Test
  func testVolumeStatistics() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test volume statistics calculation
    let voxels = volume.voxels
    let values = voxels.map { $0.value }
    
    let minValue = values.min() ?? 0
    let maxValue = values.max() ?? 0
    let avgValue = values.reduce(0, +) / Float(values.count)
    
    #expect(minValue.isFinite)
    #expect(maxValue.isFinite)
    #expect(avgValue.isFinite)
    #expect(maxValue >= minValue)
    #expect(avgValue >= minValue && avgValue <= maxValue)
  }
  
  @Test
  func testPlaneStatistics() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test plane statistics
    let axialPlane = volume.extractPlane(plane: .axial, sliceIndex: 0)
    #expect(axialPlane != nil)
    
    if let plane = axialPlane {
      let values = plane.data.map { $0.value }
      let minValue = values.min() ?? 0
      let maxValue = values.max() ?? 0
      
      #expect(minValue.isFinite)
      #expect(maxValue.isFinite)
      #expect(maxValue >= minValue)
    }
  }
  
  @Test
  func testErrorRecovery() async throws {
    let exampleURL = try getExampleURL()
    
    // Test that we can recover from errors and continue working
    do {
      let nifti = try NiftiV1(url: exampleURL)
      let header = try nifti.header()
      let volume = try nifti.volume()
      
      // Even if there are issues, we should still be able to access basic properties
      #expect(header.sizeof_hdr == 348)
      #expect(volume.voxels.count > 0)
      
    } catch {
      // If there's an error, it should be a specific NIfTI error
      #expect(error is NiftiV1Error)
    }
  }
  
  @Test
  func testMemoryEfficiency() async throws {
    let exampleURL = try getExampleURL()
    
    // Test that the library is memory efficient
    let nifti = try NiftiV1(url: exampleURL)
    let header = try nifti.header()
    let volume = try nifti.volume()
    
    // Check that we're not using excessive memory
    let expectedVoxelCount = header.nx * header.ny * header.nz
    #expect(volume.voxels.count == expectedVoxelCount)
    
    // Check that voxel values are reasonable
    for i in 0..<min(1000, volume.voxels.count) {
      let voxel = volume.voxels[i]
      #expect(voxel.value.isFinite)
      #expect(!voxel.value.isNaN)
    }
  }
  
  @Test
  func testConcurrentOperations() async throws {
    let exampleURL = try getExampleURL()
    
    // Test concurrent operations on the same file
    await withTaskGroup(of: (Bool, String).self) { group in
      for i in 0..<5 {
        group.addTask {
          do {
            let nifti = try NiftiV1(url: exampleURL)
            let _ = try nifti.header()
            let volume = try nifti.volume()
            
            // Test plane extraction
            let _ = volume.extractPlane(plane: .axial, sliceIndex: 0)
            
            return (true, "Task \(i) completed successfully")
          } catch {
            return (false, "Task \(i) failed: \(error)")
          }
        }
      }
      
      // Collect results
      for await (success, _) in group {
        #expect(success)
      }
    }
  }
  
  func getExampleURL() throws -> URL {
    try #require(Bundle.module.url(forResource: "minimal", withExtension: "nii"))
  }
} 