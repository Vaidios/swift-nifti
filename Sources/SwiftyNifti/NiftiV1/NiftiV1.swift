import Foundation

/// Main entry point for reading NIfTI-1 (.nii) files.
public struct NiftiV1 {
  /// NIfTI-1 header type alias
  public typealias Header = NiftiV1Header
  /// NIfTI-1 volume type alias
  public typealias Volume = NiftiV1Volume
  
  /// The file URL of the NIfTI file
  public let url: URL
  
  /// Create a NIfTI reader for the given file URL.
  /// - Throws: `NiftiV1Error.invalidDataAccess` if the file does not exist or is not readable.
  public init(url: URL) throws {
    guard FileManager.default.fileExists(atPath: url.path),
          FileManager.default.isReadableFile(atPath: url.path) else {
      throw NiftiV1Error.invalidDataAccess
    }
    self.url = url
  }

  /// Check if a file at the given URL is a valid NIfTI file (by extension and header size).
  public static func isNiftiFile(url: URL) -> Bool {
    guard url.pathExtension.lowercased() == "nii" else { return false }
    guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
    let headerData = try? handle.read(upToCount: 348)
    return headerData?.count == 348
  }

  /// Read and parse the NIfTI header from the file.
  /// - Throws: `NiftiV1Error` if the header is invalid or cannot be read.
  public func header() throws -> NiftiV1Header {
    let headerBytes = try FileHandle.readHeaderBytes(from: url)
    let niftiBinReader = NiftiV1BinaryReader(data: headerBytes)
    return try niftiBinReader.getHeader()
  }

  /// Read the full 3D volume from the file.
  /// - Throws: `NiftiV1Error` if the volume cannot be read or parsed.
  public func volume() throws -> Volume {
    let header = try header()
    let volumeData = try FileHandle(forReadingFrom: url).availableData
    let niftiBinReader = NiftiV1BinaryReader(data: volumeData)
    let voxels = try niftiBinReader.getVoxels(using: header.dimensions, voxelOffset: Int(header.vox_offset), bytesPerVoxel: header.bytesPerVoxel, datatype: header.niftiDatatype)
    return Volume(dimensions: header.dimensions, voxels: voxels)
  }
}
