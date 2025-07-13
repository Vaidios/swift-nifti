import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct PerformanceTests {
  
  @Test
  func testHeaderReadingPerformance() async throws {
    let exampleURL = try getExampleURL()
    
    // Measure header reading performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    for _ in 0..<100 {
      let _ = try NiftiV1(url: exampleURL).header()
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Header reading should be fast (less than 1 second for 100 reads)
    #expect(duration < 1.0)
  }
  
  @Test
  func testVolumeReadingPerformance() async throws {
    let exampleURL = try getExampleURL()
    
    // Measure volume reading performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    let volume = try NiftiV1(url: exampleURL).volume()
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Volume reading should be reasonably fast (less than 5 seconds)
    #expect(duration < 5.0)
    #expect(volume.voxels.count > 0)
  }
  
  @Test
  func testPlaneExtractionPerformance() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Measure plane extraction performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    for i in 0..<min(10, volume.getMaxValue(of: .axial)) {
      let _ = volume.extractPlane(plane: .axial, sliceIndex: i)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Plane extraction should be very fast (less than 0.1 seconds for 10 planes)
    #expect(duration < 0.1)
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
    
    // Memory increase should be reasonable (less than 100MB for this test file)
    #expect(memoryIncrease < 100 * 1024 * 1024) // 100MB
    
    // Verify volume was loaded correctly
    #expect(volume.voxels.count > 0)
  }
  
  @Test
  func testBinaryReaderPerformance() throws {
    // Create test data
    let testData = Data(repeating: 0, count: 1000000) // 1MB of data
    
    // Measure binary reading performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Simulate reading operations
    for i in stride(from: 0, to: testData.count - 4, by: 4) {
      let _: UInt32 = try testData.load(at: i)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Binary reading should be very fast (less than 0.1 seconds for 1MB)
    #expect(duration < 0.1)
  }
  
  @Test
  func testVoxelAccessPerformance() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Measure voxel access performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Access first 10000 voxels
    for i in 0..<min(10000, volume.voxels.count) {
      let _ = volume.voxels[i].value
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Voxel access should be very fast (less than 0.01 seconds for 10000 voxels)
    #expect(duration < 0.01)
  }
  
  @Test
  func testPixelConversionPerformance() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Measure pixel conversion performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Convert first 1000 voxels to pixels
    for i in 0..<min(1000, volume.voxels.count) {
      let _ = volume.voxels[i].pixel
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Pixel conversion should be very fast (less than 0.01 seconds for 1000 conversions)
    #expect(duration < 0.01)
  }
  
  @Test
  func testLargeVolumeHandling() {
    // Test handling of large volumes (simulated)
    let largeDimensions = VolumeDimensions(nx: 256, ny: 256, nz: 256)
    let expectedVoxelCount = largeDimensions.nx * largeDimensions.ny * largeDimensions.nz
    
    // Create a large volume (simulated with smaller data for testing)
    let testVoxelCount = min(expectedVoxelCount, 1000000) // Limit for testing
    let voxels = Array(repeating: Voxel(value: 0.0), count: testVoxelCount)
    
    let startTime = CFAbsoluteTimeGetCurrent()
    let volume = NiftiV1Volume(dimensions: largeDimensions, voxels: voxels)
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Large volume creation should be fast (less than 1 second)
    #expect(duration < 1.0)
    #expect(volume.voxels.count == testVoxelCount)
  }
  
  @Test
  func testConcurrentAccess() async throws {
    let exampleURL = try getExampleURL()
    
    // Test concurrent access to the same file
    let startTime = CFAbsoluteTimeGetCurrent()
    
    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<10 {
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
    
    // Concurrent access should be reasonably fast (less than 10 seconds for 10 concurrent reads)
    #expect(duration < 10.0)
  }
  
  @Test
  func testDataExtensionPerformance() throws {
    // Test Data extension performance
    let testData = Data(repeating: 0, count: 100000) // 100KB of data
    
    let startTime = CFAbsoluteTimeGetCurrent()
    
    // Test vector loading performance
    for _ in 0..<100 {
      let _: [UInt8] = try testData.loadVector(length: 1000, isByteSwapped: false)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // Data extension operations should be very fast (less than 0.1 seconds)
    #expect(duration < 0.1)
  }
  
  @Test
  func testFileHandleExtensionPerformance() async throws {
    let exampleURL = try getExampleURL()
    
    // Measure FileHandle extension performance
    let startTime = CFAbsoluteTimeGetCurrent()
    
    for _ in 0..<10 {
      let _ = try FileHandle.readHeaderBytes(from: exampleURL)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    // FileHandle operations should be fast (less than 1 second for 10 reads)
    #expect(duration < 1.0)
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