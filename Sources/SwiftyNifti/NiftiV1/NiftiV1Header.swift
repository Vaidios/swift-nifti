/// Represents the header of a NIfTI-1 file, containing metadata and dimension info.
public struct NiftiV1Header {
  /// Size of the header (should be 348 for NIfTI-1)
  public var sizeof_hdr: Int32 = 0
  /// Encodes MRI slice ordering and timing
  public var dim_info: UInt8 = 0
  /// NIfTI dimension array (dim[0] = ndim, dim[1] = nx, ...)
  public var dim: [Int16] = []
  /// Number of dimensions
  public var ndim: Int { get { Int(dim[0]) } set { dim[0] = Int16(newValue) } }
  /// X dimension size
  public var nx: Int { Int(dim[1]) }
  /// Y dimension size
  public var ny: Int { Int(dim[2]) }
  /// Z dimension size
  public var nz: Int { Int(dim[3]) }
  /// T dimension size
  public var nt: Int16 { get { dim[4] } set { dim[4] = newValue } }
  /// U dimension size
  public var nu: Int16 { get { dim[5] } set { dim[5] = newValue } }
  /// V dimension size
  public var nv: Int16 { get { dim[6] } set { dim[6] = newValue } }
  /// W dimension size
  public var nw: Int16 { get { dim[7] } set { dim[7] = newValue } }
  /// Volume dimensions (nx, ny, nz)
  public var dimensions: VolumeDimensions {
    VolumeDimensions(nx: nx, ny: ny, nz: nz)
  }
  /// Intent parameters (meaning depends on intent_code)
  public var intent_p1: Float = 0
  public var intent_p2: Float = 0
  public var intent_p3: Float = 0
  /// NIfTI intent code
  public var intent_code: Int16 = 0
  /// Data type (see DataType enum)
  public var datatype: Int16 = 0
  /// Bits per voxel
  public var bitpix: Int16 = 0
  /// Slice start index
  public var slice_start: Int16 = 0
  /// Pixel dimensions (pixdim[1] = dx, ...)
  public var pixdim: [Float] = []
  /// Voxel offset (start of data)
  public var vox_offset: Float = 0
  /// Data scaling slope
  public var scl_slope: Float = 0
  /// Data scaling intercept
  public var scl_inter: Float = 0
  /// Slice end index
  public var slice_end: Int16 = 0
  /// Slice code
  public var slice_code: UInt8 = 0
  /// Units for x/y/z/t
  public var xyzt_units: UInt8 = 0
  /// Calibration max
  public var cal_max: Float = 0
  /// Calibration min
  public var cal_min: Float = 0
  /// Slice duration
  public var slice_duration: Float = 0
  /// Time offset
  public var toffset: Float = 0
  /// Global max
  public var glmax: Int32 = 0
  /// Global min
  public var glmin: Int32 = 0
  /// Description string (80 bytes)
  public var descript: [UInt8] = []
  /// Description as String
  public var descriptString: String { String(bytes: descript, encoding: .utf8) ?? ""}
  /// Auxiliary file (24 bytes)
  public var aux_file: [UInt8] = []
  /// Qform code (spatial transform)
  public var qform_code: Int16 = 0
  /// Sform code (spatial transform)
  public var sform_code: Int16 = 0
  /// Quaternion b
  public var quatern_b: Float = 0
  /// Quaternion c
  public var quatern_c: Float = 0
  /// Quaternion d
  public var quatern_d: Float = 0
  /// Quaternion x offset
  public var qoffset_x: Float = 0
  /// Quaternion y offset
  public var qoffset_y: Float = 0
  /// Quaternion z offset
  public var qoffset_z: Float = 0
  /// Sform row x
  public var srow_x: [Float] = []
  /// Sform row y
  public var srow_y: [Float] = []
  /// Sform row z
  public var srow_z: [Float] = []
  /// Intent name (16 bytes)
  public var intent_name: [UInt8] = []
  /// Intent name as String
  public var intent_nameString: String { String(bytes: intent_name, encoding: .utf8) ?? ""}
  /// Magic string (4 bytes)
  public var magic: [UInt8] = []
  /// Magic as String
  public var magicString: String { String(bytes: magic, encoding: .utf8) ?? ""}
  /// Data type as enum
  public var niftiDatatype: DataType { DataType(rawValue: datatype) ?? .uint8 }
  /// Bytes per voxel
  public var bytesPerVoxel: Int {
    switch niftiDatatype {
    case .uint8: return 1
    case .int16: return 2
    case .int32: return 4
    case .float32: return 4
    case .float64: return 8
    case .rgb24: return 3
    case .int8: return 1
    case .uint16: return 2
    case .uint32: return 4
    case .int64: return 8
    case .uint64: return 8
    case .float128: return 16
    default: return 0
    }
  }
  /// File length in bytes (header + data)
  public var fileLength: Int {
    guard dim.count > 0 else { return 0 }
    var total = 1
    for i in 1 ... min(Int(dim[0]), dim.count - 1) {
      let size = dim[i]
      total *= Int(size)
    }
    total *= Int(bitpix / 8)
    total += Int(vox_offset)
    return total
  }
  /// Data type as string
  public var datatypeString: String {
    switch niftiDatatype {
    case .uint8: return "8-Bit UInt"
    case .uint16: return "16-Bit UInt"
    case .uint32: return "32-Bit UInt"
    case .uint64: return "64-Bit UInt"
    case .int8: return "8-Bit Int"
    case .int16: return "16-Bit Int"
    case .int32: return "32-Bit Int"
    case .int64: return "64-Bit Int"
    case .float32: return "32-Bit Float"
    case .float64: return "64-Bit Float"
    case .float128: return "128-Bit Float"
    default: return "Unknown"
    }
  }
  /// Data array for display (field name, value)
  public var dataArray: [(String, String)] {
    [
      ("Size of header", String(sizeof_hdr) + " Bytes"),
      ("Dimension sizes", "\(ndim) x \(nx) x \(ny) x \(nz) x \(nt) x \(nu) x \(nv) x \(nw)"),
      ("Datatype", datatypeString),
      ("Pixel dimensions", pixdim.reduce("", { (res, dim) -> String in
        return res + String(dim) + "x"
      })),
      ("qform", String(qform_code)),
      ("sform", String(sform_code)),
      ("Description", descriptString),
      ("Intent P1", "\(intent_p1)"),
      ("Intent P2", "\(intent_p2)"),
      ("Intent P3", "\(intent_p3)"),
      ("Intent code", "\(intent_code)"),
      ("Quaternion B", "\(quatern_b)"),
      ("Quaternion C", "\(quatern_c)"),
      ("Quaternion D", "\(quatern_d)"),
      ("Q offset X", "\(qoffset_x)"),
      ("Q offset Y", "\(qoffset_y)"),
      ("Q offset Z", "\(qoffset_z)"),
      ("Intent name", intent_nameString),
      ("Magic string", magicString)
    ]
  }
  /// Human-readable description
  public var description: String {
    return """
            Intent code - \(intent_code)
            Dimensions - \(dim)
            Datatype - \(datatypeString)
            Bits per voxel - \(bitpix)
            Slice start - \(slice_start)
            Slice end - \(slice_end)
            Voxel dimens - \(pixdim)
            Voxel offset - \(vox_offset)
        """
  }
  
  /// Display header information in a detailed format.
  /// Equivalent to C API's nifti_image_infodump().
  /// - Returns: Detailed header information string
  public func dumpInfo() -> String {
    """
    ===== NIfTI-1 Header Information =====
    File Format: NIfTI-1 (.nii)
    Header Size: \(sizeof_hdr) bytes
    
    === Dimensions ===
    Number of Dimensions: \(ndim)
    X Dimension (nx): \(nx)
    Y Dimension (ny): \(ny)
    Z Dimension (nz): \(nz)
    Time Dimension (nt): \(nt)
    U Dimension (nu): \(nu)
    V Dimension (nv): \(nv)
    W Dimension (nw): \(nw)
    
    === Data Information ===
    Data Type: \(datatypeString) (code: \(datatype))
    Bits per Voxel: \(bitpix)
    Bytes per Voxel: \(bytesPerVoxel)
    Voxel Offset: \(vox_offset)
    
    === Spatial Information ===
    Pixel Dimensions: \(pixdim.map { String(format: "%.3f", $0) }.joined(separator: " x "))
    Q-Form Code: \(qform_code)
    S-Form Code: \(sform_code)
    
    === Transform Information ===
    Quaternion B: \(quatern_b)
    Quaternion C: \(quatern_c)
    Quaternion D: \(quatern_d)
    Q-Offset X: \(qoffset_x)
    Q-Offset Y: \(qoffset_y)
    Q-Offset Z: \(qoffset_z)
    
    S-Form Row X: [\(srow_x.map { String(format: "%.3f", $0) }.joined(separator: ", "))]
    S-Form Row Y: [\(srow_y.map { String(format: "%.3f", $0) }.joined(separator: ", "))]
    S-Form Row Z: [\(srow_z.map { String(format: "%.3f", $0) }.joined(separator: ", "))]
    
    === Intent Information ===
    Intent Code: \(intent_code)
    Intent P1: \(intent_p1)
    Intent P2: \(intent_p2)
    Intent P3: \(intent_p3)
    Intent Name: "\(intent_nameString)"
    
    === Scaling Information ===
    Scale Slope: \(scl_slope)
    Scale Intercept: \(scl_inter)
    Calibration Max: \(cal_max)
    Calibration Min: \(cal_min)
    Global Max: \(glmax)
    Global Min: \(glmin)
    
    === Slice Information ===
    Slice Start: \(slice_start)
    Slice End: \(slice_end)
    Slice Code: \(slice_code)
    Slice Duration: \(slice_duration)
    Time Offset: \(toffset)
    
    === Units ===
    XYZT Units: \(xyzt_units)
    
    === Metadata ===
    Description: "\(descriptString)"
    Auxiliary File: "\(String(bytes: aux_file, encoding: .utf8) ?? "")"
    Magic String: "\(magicString)"
    
    === File Information ===
    Total File Length: \(fileLength) bytes
    Data Size: \(fileLength - Int(vox_offset)) bytes
    Total Voxels: \(nx * ny * nz)
    ======================================
    """
  }
  
  /// Convert header to ASCII format.
  /// Equivalent to C API's nifti_image_to_ascii().
  /// - Returns: ASCII representation of the header
  public func toAscii() -> String {
    var ascii = ""
    
    // Header size
    ascii += "sizeof_hdr\t\(sizeof_hdr)\n"
    
    // Dimensions
    ascii += "dim_info\t\(dim_info)\n"
    for (i, dim) in dim.enumerated() {
      ascii += "dim[\(i)]\t\(dim)\n"
    }
    
    // Intent parameters
    ascii += "intent_p1\t\(intent_p1)\n"
    ascii += "intent_p2\t\(intent_p2)\n"
    ascii += "intent_p3\t\(intent_p3)\n"
    ascii += "intent_code\t\(intent_code)\n"
    
    // Data type information
    ascii += "datatype\t\(datatype)\n"
    ascii += "bitpix\t\(bitpix)\n"
    
    // Slice information
    ascii += "slice_start\t\(slice_start)\n"
    
    // Pixel dimensions
    for (i, pix) in pixdim.enumerated() {
      ascii += "pixdim[\(i)]\t\(pix)\n"
    }
    
    // Voxel offset and scaling
    ascii += "vox_offset\t\(vox_offset)\n"
    ascii += "scl_slope\t\(scl_slope)\n"
    ascii += "scl_inter\t\(scl_inter)\n"
    
    // Slice end and code
    ascii += "slice_end\t\(slice_end)\n"
    ascii += "slice_code\t\(slice_code)\n"
    
    // Units
    ascii += "xyzt_units\t\(xyzt_units)\n"
    
    // Calibration
    ascii += "cal_max\t\(cal_max)\n"
    ascii += "cal_min\t\(cal_min)\n"
    
    // Duration and offset
    ascii += "slice_duration\t\(slice_duration)\n"
    ascii += "toffset\t\(toffset)\n"
    
    // Global min/max
    ascii += "glmax\t\(glmax)\n"
    ascii += "glmin\t\(glmin)\n"
    
    // Description and aux file
    ascii += "descript\t\"\(descriptString)\"\n"
    ascii += "aux_file\t\"\(String(bytes: aux_file, encoding: .utf8) ?? "")\"\n"
    
    // Transform codes
    ascii += "qform_code\t\(qform_code)\n"
    ascii += "sform_code\t\(sform_code)\n"
    
    // Quaternions
    ascii += "quatern_b\t\(quatern_b)\n"
    ascii += "quatern_c\t\(quatern_c)\n"
    ascii += "quatern_d\t\(quatern_d)\n"
    
    // Quaternion offsets
    ascii += "qoffset_x\t\(qoffset_x)\n"
    ascii += "qoffset_y\t\(qoffset_y)\n"
    ascii += "qoffset_z\t\(qoffset_z)\n"
    
    // S-form rows
    for (i, val) in srow_x.enumerated() {
      ascii += "srow_x[\(i)]\t\(val)\n"
    }
    for (i, val) in srow_y.enumerated() {
      ascii += "srow_y[\(i)]\t\(val)\n"
    }
    for (i, val) in srow_z.enumerated() {
      ascii += "srow_z[\(i)]\t\(val)\n"
    }
    
    // Intent name and magic
    ascii += "intent_name\t\"\(intent_nameString)\"\n"
    ascii += "magic\t\"\(magicString)\"\n"
    
    return ascii
  }
  
  /// Pixel spacing in X (pixdim[1])
  public var dx: Float { pixdim.count > 1 ? pixdim[1] : 0 }
  /// Pixel spacing in Y (pixdim[2])
  public var dy: Float { pixdim.count > 2 ? pixdim[2] : 0 }
  /// Pixel spacing in Z (pixdim[3])
  public var dz: Float { pixdim.count > 3 ? pixdim[3] : 0 }
  /// Pixel spacing in T (pixdim[4])
  public var dt: Float { pixdim.count > 4 ? pixdim[4] : 0 }
  /// Pixel spacing in U (pixdim[5])
  public var du: Float { pixdim.count > 5 ? pixdim[5] : 0 }
  /// Pixel spacing in V (pixdim[6])
  public var dv: Float { pixdim.count > 6 ? pixdim[6] : 0 }
  /// Pixel spacing in W (pixdim[7])
  public var dw: Float { pixdim.count > 7 ? pixdim[7] : 0 }
}

/// Known from C as xyzt_units
enum DimensionUnits: Int16 {
  case unknown = 0
  case metres = 1
  case millimetres = 2
  case micrometres = 3
  case seconds = 8
  case milliseconds = 16
  case microseconds = 24
  case hertz = 32
  case ppm = 40
  case rads = 48
}

public enum DataType: Int16 {
  case uint8 = 2
  case int16 = 4
  case int32 = 8
  case float32 = 16
  case complex64 = 32
  case float64 = 64
  case rgb24 = 128
  case int8 = 256
  case uint16 = 512
  case uint32 = 768
  case int64 = 1024
  case uint64 = 1280
  case float128 = 1536
  case complex128 = 1792
  case complex256 = 2048
  case rgba32 = 2304
}

extension DataType {
  var bytesPerVoxel: Int {
    switch self {
    case .uint8: return 1
    case .int16: return 2
    case .int32: return 4
    case .float32: return 4
    case .float64: return 8
    case .rgb24: return 3
    case .int8: return 1
    case .uint16: return 2
    case .uint32: return 4
    case .int64: return 8
    case .uint64: return 8
    case .float128: return 16
    case .complex64: return 8 //Check if it is correct
    case .complex128: return 16 //Check if it is correct
    case .complex256: return 32 //Check if it is correct
    case .rgba32: return 4 //Check if it is correct
    }
  }
}

enum NiftiOrientation: CustomStringConvertible {
  case L2R, R2L, P2A, A2P, I2S, S2I
  var description: String {
    switch self {
    case .L2R: return "Left-to-Right"
    case .R2L: return "Right-to-Left"
    case .P2A: return "Posterior-to-Anterior"
    case .A2P: return "Anterior-to-Posterior"
    case .I2S: return "Inferior-to-Superior"
    case .S2I: return "Superior-to-Inferior"
    }
  }
}
