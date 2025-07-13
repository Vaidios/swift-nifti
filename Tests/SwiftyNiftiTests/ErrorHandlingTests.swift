import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct ErrorHandlingTests {
  
  @Test
  func testInvalidFileURL() {
    // Test with non-existent file
    let invalidURL = URL(fileURLWithPath: "/nonexistent/file.nii")
    
    do {
      let _ = try NiftiV1(url: invalidURL)
      #expect(Bool(false), "Should throw error for invalid file")
    } catch {
      // Should throw an error
      #expect(Bool(true))
    }
  }
  
  @Test
  func testInvalidHeaderSize() {
    // Create invalid data with wrong header size
    var invalidData = Data(count: 348)
    invalidData.withUnsafeMutableBytes { ptr in
      ptr.storeBytes(of: Int32(100), as: Int32.self) // Wrong header size
    }
    
    let reader = NiftiV1BinaryReader(data: invalidData)
    
    do {
      let _ = try reader.getHeader()
      #expect(Bool(false), "Should throw error for invalid header size")
    } catch NiftiV1Error.invalidHeaderSize {
      #expect(Bool(true))
    } catch {
      #expect(Bool(false), "Should throw invalidHeaderSize error")
    }
  }
  
  @Test
  func testInvalidDimensions() {
    // Test with empty data which should cause dimension issues
    let reader = NiftiV1BinaryReader(data: Data())
    
    do {
      let _ = try reader.getHeader()
      #expect(Bool(false), "Should throw error for invalid dimensions")
    } catch {
      #expect(Bool(true))
    }
  }
  
  @Test
  func testUnsupportedDataFormat() {
    // Test with unsupported data type
    let header = createTestHeader(datatype: DataType.int64.rawValue)
    let reader = NiftiV1BinaryReader(data: Data())
    
    do {
      let _ = try reader.getVoxels(using: header)
      #expect(Bool(false), "Should throw error for unsupported data format")
    } catch NiftiV1Error.unsupportedDataFormat {
      #expect(Bool(true))
    } catch {
      #expect(Bool(false), "Should throw unsupportedDataFormat error")
    }
  }
  
  @Test
  func testInvalidPlaneIndex() async throws {
    let exampleURL = try getExampleURL()
    let volume = try NiftiV1(url: exampleURL).volume()
    
    // Test with invalid plane indices
    let invalidAxial = volume.extractPlane(plane: .axial, sliceIndex: -1)
    #expect(invalidAxial == nil)
    
    let invalidCoronal = volume.extractPlane(plane: .coronal, sliceIndex: 100)
    #expect(invalidCoronal == nil)
    
    let invalidSagittal = volume.extractPlane(plane: .sagittal, sliceIndex: 1000)
    #expect(invalidSagittal == nil)
  }
  
  @Test
  func testEmptyData() {
    // Test with empty data
    let reader = NiftiV1BinaryReader(data: Data())
    
    do {
      let _ = try reader.getHeader()
      #expect(Bool(false), "Should throw error for empty data")
    } catch {
      #expect(Bool(true))
    }
  }
  
  @Test
  func testInsufficientData() {
    // Test with insufficient data for header
    let insufficientData = Data(count: 100) // Less than 348 bytes
    let reader = NiftiV1BinaryReader(data: insufficientData)
    
    do {
      let _ = try reader.getHeader()
      #expect(Bool(false), "Should throw error for insufficient data")
    } catch {
      #expect(Bool(true))
    }
  }
  
  @Test
  func testInvalidVoxelOffset() {
    // Test with invalid voxel offset
    let header = createTestHeader(voxOffset: 1000) // Offset beyond data size
    let reader = NiftiV1BinaryReader(data: Data(count: 500))
    
    do {
      let _ = try reader.getVoxels(using: header)
      #expect(Bool(false), "Should throw error for invalid voxel offset")
    } catch {
      #expect(Bool(true))
    }
  }
  
  @Test
  func testInvalidDataType() {
    // Test with invalid data type
    let header = createTestHeader(datatype: 9999) // Invalid data type
    let reader = NiftiV1BinaryReader(data: Data())
    
    do {
      let _ = try reader.getVoxels(using: header)
      #expect(Bool(false), "Should throw error for invalid data type")
    } catch {
      #expect(Bool(true))
    }
  }
  
  @Test
  func testFileHandleErrors() {
    // Test FileHandle extension errors
    let invalidURL = URL(fileURLWithPath: "/nonexistent/file.nii")
    
    do {
      let _ = try FileHandle.readHeaderBytes(from: invalidURL)
      #expect(Bool(false), "Should throw error for invalid file")
    } catch {
      #expect(Bool(true))
    }
  }
  
  @Test
  func testDataLoadingErrors() {
    // Test Data extension error handling
    let testData = Data([0x01, 0x02, 0x03])
    
    // This should not throw an error in the current implementation
    // but we can test that it handles the data correctly
    let value: UInt8 = testData.load(at: 0)
    #expect(value == 0x01)
  }
  
  @Test
  func testVectorLoadingErrors() {
    // Test vector loading with invalid parameters
    let testData = Data([0x01, 0x02, 0x03, 0x04])
    
    // This should not throw an error in the current implementation
    // but we can test that it handles the data correctly
    let values: [UInt8] = testData.loadVector(length: 4, isByteSwapped: false)
    #expect(values.count == 4)
    #expect(values[0] == 0x01)
    #expect(values[1] == 0x02)
    #expect(values[2] == 0x03)
    #expect(values[3] == 0x04)
  }
  
  @Test
  func testHeaderValidation() {
    // Test header field validation
    let header = createTestHeader()
    
    // Test that header has valid values
    #expect(header.sizeof_hdr == 348)
    #expect(header.ndim > 0)
    #expect(header.nx > 0)
    #expect(header.ny > 0)
    #expect(header.nz > 0)
    #expect(header.bitpix > 0)
    #expect(header.bytesPerVoxel > 0)
  }
  
  @Test
  func testVolumeValidation() {
    // Test volume validation
    let dimensions = VolumeDimensions(nx: 10, ny: 10, nz: 10)
    let voxels = Array(repeating: Voxel(value: 0.0), count: 1000)
    
    let volume = NiftiV1Volume(dimensions: dimensions, voxels: voxels)
    
    // Test that volume has valid properties
    #expect(volume.dimensions.nx > 0)
    #expect(volume.dimensions.ny > 0)
    #expect(volume.dimensions.nz > 0)
    #expect(volume.voxels.count > 0)
  }
  
  @Test
  func testPlaneValidation() {
    // Test plane validation
    let data = Array(repeating: Voxel(value: 0.0), count: 100)
    let plane = Plane(data: data, width: 10, height: 10)
    
    // Test that plane has valid properties
    #expect(plane.width > 0)
    #expect(plane.height > 0)
    #expect(plane.data.count == plane.width * plane.height)
  }
  
  // Helper function to create test headers
  private func createTestHeader(
    datatype: Int16 = DataType.uint8.rawValue,
    voxOffset: Float = 352.0
  ) -> NiftiV1Header {
    var header = NiftiV1Header()
    header.sizeof_hdr = 348
    header.dim = [3, 10, 10, 10, 1, 1, 1, 1]
    header.datatype = datatype
    header.bitpix = Int16(datatype == DataType.uint8.rawValue ? 8 : 16)
    header.vox_offset = voxOffset
    header.pixdim = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
    return header
  }
  
  func getExampleURL() throws -> URL {
    try #require(Bundle.module.url(forResource: "minimal", withExtension: "nii"))
  }
} 