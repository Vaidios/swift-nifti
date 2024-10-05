import Foundation
import Testing
@testable import SwiftyNifti

@Suite
struct BinaryReaderTests {
  
  @Test
  func testUInt8DataWithProperSizeParsing() throws {
    let volumeData = volumeData
    let volumeDimensions = VolumeDimensions(nx: 4, ny: 4, nz: 4)
    let reader = NiftiV1BinaryReader(data: Data(volumeData))
    let volume = try reader.getVoxels(using: volumeDimensions, voxelOffset: 0, bytesPerVoxel: 1, datatype: .uint8)
    #expect(volume.count == volumeData.count)
  }
  
  @Test
  func testUInt8DataWithOffsetParsing() throws {
    let volumeData = volumeData
    let volumeDimensions = VolumeDimensions(nx: 4, ny: 4, nz: 4)
    let reader = NiftiV1BinaryReader(data: Data([0] + volumeData))
    let volume = try reader.getVoxels(using: volumeDimensions, voxelOffset: 1, bytesPerVoxel: 1, datatype: .uint8)
    #expect(volume.count == volumeData.count)
  }
  
  @Test
  func testUInt16DataWithOffsetParsing() throws {
    let volumeData = volumeData
    let rawData = volumeData.map { value in
      var value = value
      let data = Data(bytes: &value, count: MemoryLayout<UInt16>.size)
      return data
    }.flatMap { data in
      Array(data)
    }
    let volumeDimensions = VolumeDimensions(nx: 4, ny: 4, nz: 4)
    let reader = NiftiV1BinaryReader(data: Data([0] + rawData))
    let sut = try reader.getVoxels(using: volumeDimensions, voxelOffset: 1, bytesPerVoxel: 2, datatype: .uint16)
    #expect(sut.count == volumeData.count)
  }
}
