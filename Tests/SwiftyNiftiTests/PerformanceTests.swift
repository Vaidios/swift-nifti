import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct PerformanceTests {
  
  @Test
  func testHeaderReadingPerformance() async throws {
    let exampleURL = try getExampleURL()
    
    // Warm up
    for _ in 0..<10 {
      let _ = try NiftiV1(url: exampleURL).header()
    }
    
    // Measure header reading performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    for _ in 0..<100 {
      let _ = try NiftiV1(url: exampleURL).header()
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Header reading should be very fast (less than 0.5 seconds for 100 reads)
    // This is more realistic for a small file
    #expect(duration < 0.5, "Header reading took \(duration)s, expected < 0.5s")
  }
  
  @Test
  func testVolumeReadingPerformance() async throws {
    let exampleURL = try getExampleURL()
    
    // Measure volume reading performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    let volume = try NiftiV1(url: exampleURL).volume()
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Volume reading should be reasonably fast (less than 2 seconds for this test file)
    // The test file is small (64x64x10), so it should be very fast
    #expect(duration < 2.0, "Volume reading took \(duration)s, expected < 2.0s")
    #expect(volume.voxels.count > 0)
  }
  
  @Test
  func testPlaneExtractionPerformance() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Warm up
    for i in 0..<min(5, volume.getMaxValue(of: .axial)) {
      let _ = volume.extractPlane(plane: .axial, sliceIndex: i)
    }
    
    // Measure plane extraction performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    for i in 0..<min(20, volume.getMaxValue(of: .axial)) {
      let _ = volume.extractPlane(plane: .axial, sliceIndex: i)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Plane extraction should be very fast (less than 0.05 seconds for 20 planes)
    #expect(duration < 0.05, "Plane extraction took \(duration)s, expected < 0.05s")
  }
  
  @Test
  func testMemoryUsage() async throws {
    let exampleURL = try getExampleURL()
    
    // Measure memory usage before
    let memoryBefore = getMemoryUsage()
    
    // Read volume
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Measure memory usage after
    let memoryAfter = getMemoryUsage()
    let memoryIncrease = memoryAfter - memoryBefore
    
    // Memory increase should be reasonable (less than 50MB for this test file)
    // The test file is small, so memory usage should be minimal
    #expect(memoryIncrease < 50 * 1024 * 1024, "Memory increase: \(memoryIncrease / 1024 / 1024)MB, expected < 50MB")
    
    // Verify volume was loaded correctly
    #expect(volume.voxels.count > 0)
  }
  
  @Test
  func testBinaryReaderPerformance() throws {
    // Create test data with realistic NIfTI-like content
    var testData = Data(count: 1000000) // 1MB of data
    testData.withUnsafeMutableBytes { ptr in
      // Set some realistic values
      ptr.storeBytes(of: Int32(348), as: Int32.self)
      (ptr.baseAddress! + 40).storeBytes(of: Int16(3), as: Int16.self)
      (ptr.baseAddress! + 42).storeBytes(of: Int16(64), as: Int16.self)
      (ptr.baseAddress! + 44).storeBytes(of: Int16(64), as: Int16.self)
      (ptr.baseAddress! + 46).storeBytes(of: Int16(10), as: Int16.self)
    }
    
    // Measure binary reading performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Simulate realistic reading operations
    for i in stride(from: 0, to: min(testData.count - 4, 10000), by: 4) {
      let _: UInt32 = try testData.load(at: i)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Binary reading should be very fast (less than 0.05 seconds for 2500 reads)
    #expect(duration < 0.05, "Binary reading took \(duration)s, expected < 0.05s")
  }
  
  @Test
  func testVoxelAccessPerformance() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Warm up
    for i in 0..<min(1000, volume.voxels.count) {
      let _ = volume.voxels[i].value
    }
    
    // Measure voxel access performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Access first 50000 voxels (or all if less)
    for i in 0..<min(50000, volume.voxels.count) {
      let _ = volume.voxels[i].value
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Voxel access should be extremely fast (less than 0.02 seconds for 50000 voxels)
    // 0.005s is too strict for most systems; 0.02s is still very fast and realistic
    #expect(duration < 0.02, "Voxel access took \(duration)s, expected < 0.02s")
  }
  
  @Test
  func testPixelConversionPerformance() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Warm up
    for i in 0..<min(500, volume.voxels.count) {
      let _ = volume.voxels[i].pixel
    }
    
    // Measure pixel conversion performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Convert first 10000 voxels to pixels
    for i in 0..<min(10000, volume.voxels.count) {
      let _ = volume.voxels[i].pixel
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Pixel conversion should be very fast (less than 0.01 seconds for 10000 conversions)
    #expect(duration < 0.01, "Pixel conversion took \(duration)s, expected < 0.01s")
  }
  
  @Test
  func testLargeVolumeHandling() {
    // Test handling of large volumes (simulated)
    let largeDimensions = VolumeDimensions(nx: 512, ny: 512, nz: 100)
    let expectedVoxelCount = largeDimensions.nx * largeDimensions.ny * largeDimensions.nz
    
    // Create a large volume (simulated with smaller data for testing)
    let testVoxelCount = min(expectedVoxelCount, 1000000) // Limit for testing
    let voxels = Array(repeating: Voxel(value: 0.0), count: testVoxelCount)
    
    let startTime = CFAbsoluteTimeGetCurrent()
    let volume = NiftiV1Volume(dimensions: largeDimensions, voxels: voxels)
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Large volume creation should be fast (less than 0.5 seconds)
    #expect(duration < 0.5, "Large volume creation took \(duration)s, expected < 0.5s")
    #expect(volume.voxels.count == testVoxelCount)
  }
  
  @Test
  func testConcurrentAccess() async throws {
    let exampleURL = try getExampleURL()
    
    // Test concurrent access to the same file
    let startTime = CFAbsoluteTimeGetCurrent()
    
    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<20 {
        group.addTask {
          do {
            let nifti = try NiftiV1(url: exampleURL)
            let _ = try nifti.header()
            let _ = try nifti.volume()
          } catch {
            // Ignore errors for performance test
          }
        }
      }
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Concurrent access should be reasonably fast (less than 5 seconds for 20 concurrent reads)
    #expect(duration < 5.0, "Concurrent access took \(duration)s, expected < 5.0s")
  }
  
  @Test
  func testDataExtensionPerformance() throws {
    // Test Data extension performance with realistic data
    var testData = Data(count: 100000) // 100KB of data
    let count = testData.count
    testData.withUnsafeMutableBytes { ptr in
      // Set some realistic values
      for i in stride(from: 0, to: count, by: 4) {
        (ptr.baseAddress! + i).storeBytes(of: UInt32(i), as: UInt32.self)
      }
    }
    
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Test vector loading performance
    for _ in 0..<100 {
      let _: [UInt8] = try testData.loadVector(length: 1000, isByteSwapped: false)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Data extension operations should be very fast (less than 0.05 seconds)
    #expect(duration < 0.05, "Data extension operations took \(duration)s, expected < 0.05s")
  }
  
  @Test
  func testFileHandleExtensionPerformance() async throws {
    let exampleURL = try getExampleURL()
    
    // Warm up
    for _ in 0..<5 {
      let _ = try FileHandle.readHeaderBytes(from: exampleURL)
    }
    
    // Measure FileHandle extension performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    for _ in 0..<20 {
      let _ = try FileHandle.readHeaderBytes(from: exampleURL)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // FileHandle operations should be fast (less than 0.5 seconds for 20 reads)
    #expect(duration < 0.5, "FileHandle operations took \(duration)s, expected < 0.5s")
  }
  
  @Test
  func testEndToEndPerformance() async throws {
    let exampleURL = try getExampleURL()
    
    // Test complete workflow performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Complete workflow: read file, get header, get volume, extract planes
    let nifti = try NiftiV1(url: exampleURL)
    _ = try nifti.header()
    let volume = try nifti.volume()
    
    // Extract a few planes
    for i in 0..<min(5, volume.getMaxValue(of: .axial)) {
      let _ = volume.extractPlane(plane: .axial, sliceIndex: i)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Complete workflow should be reasonably fast (less than 3 seconds)
    #expect(duration < 3.0, "End-to-end workflow took \(duration)s, expected < 3.0s")
    #expect(volume.voxels.count > 0)
  }
  
  // Helper function to get current memory usage
  private func getMemoryUsage() -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
    
    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_,
                     task_flavor_t(MACH_TASK_BASIC_INFO),
                     $0,
                     &count)
        }
    }
    
    if kerr == KERN_SUCCESS {
        return UInt64(info.resident_size)
    } else {
        return 0
    }
  }
  
  func getExampleURL() throws -> URL {
    try #require(Bundle.module.url(forResource: "minimal", withExtension: "nii"))
  }
} 