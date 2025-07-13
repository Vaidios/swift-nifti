import Foundation

/// Binary writer for NIfTI-1 files.
/// Handles writing headers and volume data to NIfTI format.
final class NiftiV1BinaryWriter {
  
  /// Write a NIfTI file with header and volume data.
  /// - Parameters:
  ///   - header: The NIfTI header to write
  ///   - volume: The volume data to write
  ///   - outputURL: The output file URL
  /// - Throws: `NiftiV1Error` if writing fails
  func write(header: NiftiV1Header, volume: NiftiV1Volume, to outputURL: URL) throws {
    let fileHandle = try FileHandle(forWritingTo: outputURL)
    defer { 
      if #available(macOS 10.15, *) {
        try? fileHandle.close()
      }
    }
    
    // Write header
    try writeHeader(header, to: fileHandle)
    
    // Write volume data
    try writeVolumeData(volume, to: fileHandle)
  }
  
  /// Helper to write a value of type T at a specific offset in a Data buffer
  private func writeValue<T>(_ value: T, to data: inout Data, at offset: Int) {
    withUnsafeBytes(of: value) { valuePtr in
      data.replaceSubrange(offset..<(offset + MemoryLayout<T>.size), with: valuePtr)
    }
  }

  /// Write header data to file handle.
  /// - Parameters:
  ///   - header: The header to write
  ///   - fileHandle: The file handle to write to
  /// - Throws: `NiftiV1Error` if writing fails
  private func writeHeader(_ header: NiftiV1Header, to fileHandle: FileHandle) throws {
    var headerData = Data(count: 348)
    
    // Write header size
    writeValue(header.sizeof_hdr, to: &headerData, at: 0)
    // Write dim_info
    writeValue(header.dim_info, to: &headerData, at: 39)
    // Write dimensions array
    for (i, dim) in header.dim.enumerated() {
      writeValue(dim, to: &headerData, at: 40 + i * 2)
    }
    // Write intent parameters
    writeValue(header.intent_p1, to: &headerData, at: 56)
    writeValue(header.intent_p2, to: &headerData, at: 60)
    writeValue(header.intent_p3, to: &headerData, at: 64)
    // Write intent code
    writeValue(header.intent_code, to: &headerData, at: 68)
    // Write datatype and bitpix
    writeValue(header.datatype, to: &headerData, at: 70)
    writeValue(header.bitpix, to: &headerData, at: 72)
    // Write slice_start
    writeValue(header.slice_start, to: &headerData, at: 74)
    // Write pixdim array
    for (i, pix) in header.pixdim.enumerated() {
      writeValue(pix, to: &headerData, at: 76 + i * 4)
    }
    // Write vox_offset
    writeValue(header.vox_offset, to: &headerData, at: 108)
    // Write scaling parameters
    writeValue(header.scl_slope, to: &headerData, at: 112)
    writeValue(header.scl_inter, to: &headerData, at: 116)
    // Write slice_end and slice_code
    writeValue(header.slice_end, to: &headerData, at: 120)
    writeValue(header.slice_code, to: &headerData, at: 122)
    // Write xyzt_units
    writeValue(header.xyzt_units, to: &headerData, at: 123)
    // Write calibration values
    writeValue(header.cal_max, to: &headerData, at: 124)
    writeValue(header.cal_min, to: &headerData, at: 128)
    // Write slice_duration and toffset
    writeValue(header.slice_duration, to: &headerData, at: 132)
    writeValue(header.toffset, to: &headerData, at: 136)
    // Write global min/max
    writeValue(header.glmax, to: &headerData, at: 140)
    writeValue(header.glmin, to: &headerData, at: 144)
    // Write description
    for (i, byte) in header.descript.enumerated() {
      writeValue(byte, to: &headerData, at: 148 + i)
    }
    // Write aux_file
    for (i, byte) in header.aux_file.enumerated() {
      writeValue(byte, to: &headerData, at: 228 + i)
    }
    // Write transform codes
    writeValue(header.qform_code, to: &headerData, at: 252)
    writeValue(header.sform_code, to: &headerData, at: 254)
    // Write quaternions
    writeValue(header.quatern_b, to: &headerData, at: 256)
    writeValue(header.quatern_c, to: &headerData, at: 260)
    writeValue(header.quatern_d, to: &headerData, at: 264)
    // Write quaternion offsets
    writeValue(header.qoffset_x, to: &headerData, at: 268)
    writeValue(header.qoffset_y, to: &headerData, at: 272)
    writeValue(header.qoffset_z, to: &headerData, at: 276)
    // Write s-form rows
    for (i, val) in header.srow_x.enumerated() {
      writeValue(val, to: &headerData, at: 280 + i * 4)
    }
    for (i, val) in header.srow_y.enumerated() {
      writeValue(val, to: &headerData, at: 296 + i * 4)
    }
    for (i, val) in header.srow_z.enumerated() {
      writeValue(val, to: &headerData, at: 312 + i * 4)
    }
    // Write intent_name
    for (i, byte) in header.intent_name.enumerated() {
      writeValue(byte, to: &headerData, at: 328 + i)
    }
    // Write magic string
    for (i, byte) in header.magic.enumerated() {
      writeValue(byte, to: &headerData, at: 344 + i)
    }
    // Write header to file
    fileHandle.write(headerData)
  }
  
  /// Write volume data to file handle.
  /// - Parameters:
  ///   - volume: The volume data to write
  ///   - fileHandle: The file handle to write to
  /// - Throws: `NiftiV1Error` if writing fails
  private func writeVolumeData(_ volume: NiftiV1Volume, to fileHandle: FileHandle) throws {
    // Convert voxels to raw data based on data type
    // For now, we'll write as Float32 since that's what our Voxel type uses
    let voxelData = volume.voxels.map { $0.value }
    var rawData = Data(count: voxelData.count * MemoryLayout<Float>.size)
    for (i, value) in voxelData.enumerated() {
      writeValue(Float(value), to: &rawData, at: i * MemoryLayout<Float>.size)
    }
    fileHandle.write(rawData)
  }
} 