import Foundation

public struct NiftiV1 {
  
  public typealias Header = NiftiV1Header
  public typealias Volume = NiftiV1Volume
  
  public let url: URL
  
  public init(url: URL) throws {
    self.url = url
  }
  
  public func header() throws -> NiftiV1.Header {
    let headerBytes = try FileHandle.readHeaderBytes(from: url)
    let niftiBinReader = NiftiV1BinaryReader(data: headerBytes)
    return try niftiBinReader.getHeader()
  }
  
  public func volume() throws -> Volume {
    let header = try header()
    let volumeData = try FileHandle(forReadingFrom: url).availableData
    let niftiBinReader = NiftiV1BinaryReader(data: volumeData)
//    let voxels = try niftiBinReader.getVoxels(using: header)
    let voxels = try niftiBinReader.getVoxels(using: header.dimensions, voxelOffset: Int(header.vox_offset), bytesPerVoxel: header.bytesPerVoxel, datatype: header.niftiDatatype)
    return Volume(dimensions: header.dimensions, voxels: voxels)
  }
}
