public struct NiftiV1Header {
  
  public var sizeof_hdr: Int32 = 0 // 0 offset
  public var dim_info: UInt8 = 0

  public var ndim: Int { get { Int(dim[0]) } set { dim[0] = Int16(newValue) } }
  public var nx: Int { Int(dim[1]) }
  public var ny: Int { Int(dim[2]) }
  public var nz: Int { Int(dim[3]) }
  public var nt: Int16 { get { dim[4] } set { dim[4] = newValue } }
  public var nu: Int16 { get { dim[5] } set { dim[5] = newValue } }
  public var nv: Int16 { get { dim[6] } set { dim[6] = newValue } }
  public var nw: Int16 { get { dim[7] } set { dim[7] = newValue } }
  public var dim: [Int16] = [] // 40
  public var dimensions: VolumeDimensions {
    VolumeDimensions(nx: nx, ny: ny, nz: nz)
  }
  
  public var intent_p1: Float = 0
  public var intent_p2: Float = 0
  public var intent_p3: Float = 0
  public var intent_code: Int16 = 0
  
  public var niftiDatatype: DataType { DataType(rawValue: datatype)! }
  public var datatype: Int16 = 0 //70
  public var bitpix: Int16 = 0
  public var slice_start: Int16 = 0
  
  public var dx: Float { pixdim[1] * Float(nx) }
  public var dy: Float { pixdim[2] * Float(ny) }
  public var dz: Float { pixdim[3] * Float(nz) }
  public var dt: Float { pixdim[4] * Float(nt) }
  public var du: Float { pixdim[5] * Float(nu) }
  public var dv: Float { pixdim[6] * Float(nv) }
  public var dw: Float { pixdim[7] * Float(nw) }
  public var pixdim: [Float] = []
  
  public var nvox: Int = 0
  public var vox_offset: Float = 0
  public var scl_slope: Float = 0
  public var scl_inter: Float = 0
  public var slice_end: Int16 = 0
  public var slice_code: UInt8 = 0
  public var xyzt_units: UInt8 = 0
  public var cal_max: Float = 0
  public var cal_min: Float = 0
  public var slice_duration: Float = 0
  public var toffset: Float = 0
  
  public var glmax: Int32 = 0
  public var glmin: Int32 = 0
  
  public var descript: [UInt8] = []
  public var descriptString: String { String(bytes: descript, encoding: .utf8) ?? ""}
  
  public var aux_file: [UInt8] = []
  
  public var qform_code: Int16 = 0
  public var sform_code: Int16 = 0
  
  public var quatern_b: Float = 0
  public var quatern_c: Float = 0
  public var quatern_d: Float = 0
  public var qoffset_x: Float = 0
  public var qoffset_y: Float = 0
  public var qoffset_z: Float = 0
  
  public var srow_x: [Float] = []
  public var srow_y: [Float] = []
  public var srow_z: [Float] = []

  public var intent_name: [UInt8] = []
  public var intent_nameString: String { String(bytes: intent_name, encoding: .utf8) ?? ""}
  
  public var magic: [UInt8] = []
  public var magicString: String { String(bytes: magic, encoding: .utf8) ?? ""}
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
    var total = 1
    for i in 1 ... Int(dim[0]) {
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
