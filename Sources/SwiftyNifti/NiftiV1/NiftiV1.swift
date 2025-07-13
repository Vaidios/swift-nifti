import Foundation

/// Main entry point for reading and writing NIfTI-1 (.nii) files.
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
  /// Equivalent to C API's nifti_is_valid_filename().
  public static func isNiftiFile(url: URL) -> Bool {
    guard url.pathExtension.lowercased() == "nii" else { return false }
    guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
    if #available(macOS 10.15.4, *) {
      let headerData = try? handle.read(upToCount: 348)
      return headerData?.count == 348
    } else {
      // Fallback for older macOS versions
      let headerData = try? handle.readData(ofLength: 348)
      return headerData?.count == 348
    }
  }

  /// Read and parse the NIfTI header from the file.
  /// Equivalent to C API's nifti_read_header().
  /// - Throws: `NiftiV1Error` if the header is invalid or cannot be read.
  public func header() throws -> NiftiV1Header {
    let headerBytes = try FileHandle.readHeaderBytes(from: url)
    let niftiBinReader = NiftiV1BinaryReader(data: headerBytes)
    return try niftiBinReader.getHeader()
  }

  /// Read the full 3D volume from the file.
  /// Equivalent to C API's nifti_image_read().
  /// - Throws: `NiftiV1Error` if the volume cannot be read or parsed.
  public func volume() throws -> Volume {
    let header = try header()
    let volumeData = try FileHandle(forReadingFrom: url).availableData
    let niftiBinReader = NiftiV1BinaryReader(data: volumeData)
    let voxels = try niftiBinReader.getVoxels(using: header.dimensions, voxelOffset: Int(header.vox_offset), bytesPerVoxel: header.bytesPerVoxel, datatype: header.niftiDatatype)
    return Volume(dimensions: header.dimensions, voxels: voxels)
  }
  
  /// Read only the volume data without header parsing.
  /// Equivalent to C API's nifti_read_data().
  /// - Throws: `NiftiV1Error` if the data cannot be read.
  public func readData() throws -> [Voxel] {
    let header = try header()
    let volumeData = try FileHandle(forReadingFrom: url).availableData
    let niftiBinReader = NiftiV1BinaryReader(data: volumeData)
    return try niftiBinReader.getVoxels(using: header.dimensions, voxelOffset: Int(header.vox_offset), bytesPerVoxel: header.bytesPerVoxel, datatype: header.niftiDatatype)
  }
  
  /// Display header information in a human-readable format.
  /// Equivalent to C API's nifti_image_infodump().
  /// - Returns: Formatted header information string
  public func dumpHeaderInfo() throws -> String {
    let header = try header()
    return header.dumpInfo()
  }
  
  /// Write a NIfTI file with the given header and volume data.
  /// Equivalent to C API's nifti_image_write().
  /// - Parameters:
  ///   - header: The NIfTI header
  ///   - volume: The volume data to write
  ///   - outputURL: The output file URL
  /// - Throws: `NiftiV1Error` if writing fails
  public static func write(header: NiftiV1Header, volume: Volume, to outputURL: URL) throws {
    let writer = NiftiV1BinaryWriter()
    try writer.write(header: header, volume: volume, to: outputURL)
  }
  
  /// Write a NIfTI file with the given header and voxel data.
  /// - Parameters:
  ///   - header: The NIfTI header
  ///   - voxels: The voxel data to write
  ///   - outputURL: The output file URL
  /// - Throws: `NiftiV1Error` if writing fails
  public static func write(header: NiftiV1Header, voxels: [Voxel], to outputURL: URL) throws {
    let volume = Volume(dimensions: header.dimensions, voxels: voxels)
    try write(header: header, volume: volume, to: outputURL)
  }
  
  /// Convert header information to ASCII format.
  /// Equivalent to C API's nifti_image_to_ascii().
  /// - Returns: ASCII representation of the header
  public func headerToAscii() throws -> String {
    let header = try header()
    return header.toAscii()
  }
  
  /// Get file statistics and information.
  /// - Returns: File information including size, dimensions, and data type
  public func getFileInfo() throws -> FileInfo {
    let header = try header()
    let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
    let fileSize = fileAttributes[.size] as? Int64 ?? 0
    
    return FileInfo(
      url: url,
      fileSize: Int(fileSize),
      headerSize: Int(header.sizeof_hdr),
      dataSize: Int(fileSize) - Int(header.sizeof_hdr),
      dimensions: header.dimensions,
      dataType: header.niftiDatatype,
      bytesPerVoxel: header.bytesPerVoxel,
      totalVoxels: header.dimensions.nx * header.dimensions.ny * header.dimensions.nz
    )
  }
}

/// File information structure for NIfTI files
public struct FileInfo {
  /// The file URL
  public let url: URL
  /// Total file size in bytes
  public let fileSize: Int
  /// Header size in bytes
  public let headerSize: Int
  /// Data size in bytes
  public let dataSize: Int
  /// Volume dimensions
  public let dimensions: VolumeDimensions
  /// Data type
  public let dataType: DataType
  /// Bytes per voxel
  public let bytesPerVoxel: Int
  /// Total number of voxels
  public let totalVoxels: Int
  
  /// Human-readable description
  public var description: String {
    """
    File: \(url.lastPathComponent)
    Size: \(fileSize) bytes (Header: \(headerSize), Data: \(dataSize))
    Dimensions: \(dimensions.nx) x \(dimensions.ny) x \(dimensions.nz)
    Data Type: \(dataType)
    Voxels: \(totalVoxels) (\(bytesPerVoxel) bytes each)
    """
  }
}
