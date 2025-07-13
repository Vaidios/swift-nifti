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
}

extension NiftiV1Header: CustomStringConvertible {
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
}

extension NiftiV1Header {
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
}

extension NiftiV1Header {
  var fileLength: Int {
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
    
  var bytesPerVoxel: Int {
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
    default: print("BytesPerVoxel, bad enum"); return 0
    }
  }
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
