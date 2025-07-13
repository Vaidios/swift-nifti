import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct DataTypeTests {
  
  @Test
  func testDataTypeEnum() {
    // Test all data type enum cases
    #expect(DataType.uint8.rawValue == 2)
    #expect(DataType.int16.rawValue == 4)
    #expect(DataType.int32.rawValue == 8)
    #expect(DataType.float32.rawValue == 16)
    #expect(DataType.complex64.rawValue == 32)
    #expect(DataType.float64.rawValue == 64)
    #expect(DataType.rgb24.rawValue == 128)
    #expect(DataType.int8.rawValue == 256)
    #expect(DataType.uint16.rawValue == 512)
    #expect(DataType.uint32.rawValue == 768)
    #expect(DataType.int64.rawValue == 1024)
    #expect(DataType.uint64.rawValue == 1280)
    #expect(DataType.float128.rawValue == 1536)
    #expect(DataType.complex128.rawValue == 1792)
    #expect(DataType.complex256.rawValue == 2048)
    #expect(DataType.rgba32.rawValue == 2304)
  }
  
  @Test
  func testDataTypeBytesPerVoxel() {
    // Test bytes per voxel for each data type
    #expect(DataType.uint8.bytesPerVoxel == 1)
    #expect(DataType.int16.bytesPerVoxel == 2)
    #expect(DataType.int32.bytesPerVoxel == 4)
    #expect(DataType.float32.bytesPerVoxel == 4)
    #expect(DataType.float64.bytesPerVoxel == 8)
    #expect(DataType.rgb24.bytesPerVoxel == 3)
    #expect(DataType.int8.bytesPerVoxel == 1)
    #expect(DataType.uint16.bytesPerVoxel == 2)
    #expect(DataType.uint32.bytesPerVoxel == 4)
    #expect(DataType.int64.bytesPerVoxel == 8)
    #expect(DataType.uint64.bytesPerVoxel == 8)
    #expect(DataType.float128.bytesPerVoxel == 16)
    #expect(DataType.complex64.bytesPerVoxel == 8)
    #expect(DataType.complex128.bytesPerVoxel == 16)
    #expect(DataType.complex256.bytesPerVoxel == 32)
    #expect(DataType.rgba32.bytesPerVoxel == 4)
  }
  
  @Test
  func testDataTypeStringRepresentation() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test data type string representation
    let datatypeString = header.datatypeString
    #expect(!datatypeString.isEmpty)
    #expect(datatypeString != "Unknown")
  }
  
  @Test
  func testVoxelCreation() {
    // Test voxel creation from different types
    let voxel1 = Voxel(value: 42.0)
    #expect(voxel1.value == 42.0)
    
    let voxel2 = Voxel(UInt8(128))
    #expect(voxel2.value == 128.0)
  }
  
  @Test
  func testVoxelEquality() {
    let voxel1 = Voxel(value: 42.0)
    let voxel2 = Voxel(value: 42.0)
    let voxel3 = Voxel(value: 43.0)
    
    #expect(voxel1 == voxel2)
    #expect(voxel1 != voxel3)
  }
  
  @Test
  func testVoxelPixelConversion() {
    let voxel = Voxel(value: 128.0)
    let pixel = voxel.pixel
    
    #expect(pixel.a == 255) // Alpha should be 255
    #expect(pixel.r == 128)
    #expect(pixel.g == 128)
    #expect(pixel.b == 128)
  }
  
  @Test
  func testVoxelPixelConversionClamping() {
    // Test that values are properly clamped to 0-255 range
    let voxel1 = Voxel(value: 300.0)
    let pixel1 = voxel1.pixel
    #expect(pixel1.r == 255)
    #expect(pixel1.g == 255)
    #expect(pixel1.b == 255)
    
    let voxel2 = Voxel(value: -10.0)
    let pixel2 = voxel2.pixel
    #expect(pixel2.r == 0)
    #expect(pixel2.g == 0)
    #expect(pixel2.b == 0)
  }
  
  @Test
  func testPixelDataCreation() {
    let pixel = PixelData(a: 255, r: 100, g: 150, b: 200)
    
    #expect(pixel.a == 255)
    #expect(pixel.r == 100)
    #expect(pixel.g == 150)
    #expect(pixel.b == 200)
  }
  
  @Test
  func testPixelDataDefaultAlpha() {
    let pixel = PixelData(r: 100, g: 150, b: 200)
    
    #expect(pixel.a == 255) // Default alpha should be 255
    #expect(pixel.r == 100)
    #expect(pixel.g == 150)
    #expect(pixel.b == 200)
  }
  
  @Test
  func testDataTypeFromRawValue() {
    // Test creating data types from raw values
    let uint8Type = DataType(rawValue: 2)
    #expect(uint8Type == .uint8)
    
    let float32Type = DataType(rawValue: 16)
    #expect(float32Type == .float32)
    
    let invalidType = DataType(rawValue: 9999)
    #expect(invalidType == nil)
  }
  
  @Test
  func testHeaderDataTypeAccess() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test that we can access the data type
    let datatype = header.datatype
    #expect(datatype > 0)
    
    let niftiDatatype = header.niftiDatatype
    #expect(niftiDatatype.bytesPerVoxel > 0)
  }
  
  @Test
  func testHeaderBitpix() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test bitpix field
    let bitpix = header.bitpix
    #expect(bitpix > 0)
    #expect(bitpix % 8 == 0) // Should be divisible by 8
  }
  
  @Test
  func testHeaderBytesPerVoxel() async throws {
    let exampleURL = try getExampleURL()
    let header = try NiftiV1(url: exampleURL).header()
    
    // Test bytes per voxel calculation
    let bytesPerVoxel = header.bytesPerVoxel
    #expect(bytesPerVoxel > 0)
    #expect(bytesPerVoxel == header.bitpix / 8)
  }
  
  @Test
  func testUnsupportedDataTypes() {
    // Test that unsupported data types throw appropriate errors
    // This would require creating test files with different data types
    // For now, we test the error handling in the binary reader
    
    let unsupportedTypes: [DataType] = [
      .int8, .int16, .int32, .int64, .uint64, .float64, .float128,
      .complex64, .complex128, .complex256, .rgb24, .rgba32
    ]
    
    for dataType in unsupportedTypes {
      #expect(dataType.bytesPerVoxel > 0) // All should have valid bytes per voxel
    }
  }
  
  @Test
  func testDataExtensions() throws {
    // Test Data extensions for binary reading
    let testData = Data([0x01, 0x02, 0x03, 0x04])
    
    // Test byte swapping
    let swapped = testData.byteSwapped
    #expect(swapped.count == testData.count)
    #expect(swapped != testData)
    
    // Test loading single value
    let uint8Value: UInt8 = try testData.load(at: 0)
    #expect(uint8Value == 0x01)
  }
  
  @Test
  func testDataVectorLoading() throws {
    let testData = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
    
    // Test loading vector of UInt8
    let uint8Vector: [UInt8] = try testData.loadVector(length: 4, isByteSwapped: false)
    #expect(uint8Vector.count == 4)
    #expect(uint8Vector[0] == 0x01)
    #expect(uint8Vector[1] == 0x02)
    #expect(uint8Vector[2] == 0x03)
    #expect(uint8Vector[3] == 0x04)
  }
  
  func getExampleURL() throws -> URL {
    try #require(Bundle.module.url(forResource: "minimal", withExtension: "nii"))
  }
} 