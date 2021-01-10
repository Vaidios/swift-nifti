//
//  NiftiHeader.swift
//  SwiftyNifti
//
//  Created by Kamil Sosna on 02/12/2020.
//

import Foundation

public class NiftiHeaderV1 {
    public init() { }
    
    var sizeof_hdr: Int32 = 0 // 0 offset
    var dim_info: UInt8 = 0
    
    var ndim: Int { get { return Int(dim[0]) } set { dim[0] = Int16(newValue) } }
    var nx: Int { return Int(dim[1]) }
    var ny: Int { return Int(dim[2]) }
    var nz: Int { return Int(dim[3]) }
    var nt: Int16 { get { return dim[4] } set { dim[4] = newValue } }
    var nu: Int16 { get { return dim[5] } set { dim[5] = newValue } }
    var nv: Int16 { get { return dim[6] } set { dim[6] = newValue } }
    var nw: Int16 { get { return dim[7] } set { dim[7] = newValue } }
    var dim: [Int16] = [] // 40
    
    var intent_p1: Float = 0
    var intent_p2: Float = 0
    var intent_p3: Float = 0
    var intent_code: Int16 = 0
    
    public var niftiDatatype: NiftiType { return NiftiType(rawValue: datatype)! }
    var datatype: Int16 = 0 //70
    var bitpix: Int16 = 0
    var slice_start: Int16 = 0
    
    var dx: Float { return pixdim[1] * Float(nx) }
    var dy: Float { return pixdim[2] * Float(ny) }
    var dz: Float { return pixdim[3] * Float(nz) }
    var dt: Float { return pixdim[4] * Float(nt) }
    var du: Float { return pixdim[5] * Float(nu) }
    var dv: Float { return pixdim[6] * Float(nv) }
    var dw: Float { return pixdim[7] * Float(nw) }
    var pixdim: [Float] = []
    
    var nvox: Int = 0
    var vox_offset: Float = 0
    var scl_slope: Float = 0
    var scl_inter: Float = 0
    var slice_end: Int16 = 0
    var slice_code: UInt8 = 0
    var xyzt_units: UInt8 = 0
    var cal_max: Float = 0
    var cal_min: Float = 0
    var slice_duration: Float = 0
    var toffset: Float = 0
    
    var glmax: Int32 = 0
    var glmin: Int32 = 0
    
    var descript: [UInt8] = []
    var aux_file: [UInt8] = []
    
    var qform_code: Int16 = 0
    var sform_code: Int16 = 0
    
    var quatern_b: Float = 0
    var quatern_c: Float = 0
    var quatern_d: Float = 0
    var qoffset_x: Float = 0
    var qoffset_y: Float = 0
    var qoffset_z: Float = 0
    
    var srow_x: [Float] = []
    var srow_y: [Float] = []
    var srow_z: [Float] = []
    
    var intent_name: [UInt8] = []

    var magic: [UInt8] = []
}
extension NiftiHeaderV1: CustomStringConvertible {
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

extension NiftiHeaderV1 {
    public var dataArray: [(String, String)] {
        [("Size of header", String(sizeof_hdr) + " Bytes"),
         ("Dimension sizes", dim.reduce("", { (res, dim) -> String in
            return res + String(dim) + "x"
         })),
         ("Datatype", datatypeString),
         ("Pixel dimensions", pixdim.reduce("", { (res, dim) -> String in
            return res + String(dim) + "x"
         })),
         ("qform", String(qform_code)),
         ("sform", String(sform_code)),
         
        ]
    }
}

extension NiftiHeaderV1 {
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
    
    var datatypeString: String {
        switch NiftiType(rawValue: datatype) {
        case .uint8: return "8-Bit UInt"
        case .float32: return "32-Bit Float"
        case .float64: return "64-Bit Float"
        case .int16: return "16-Bit Int"
        case .int32: return "32-Bit Int"

        default: return "Unknown"
        }
    }
    
    var bytesPerVoxel: Int {
        switch NiftiType(rawValue: datatype) {
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

enum xyzt_Units: Int16 {
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

public enum NiftiType: Int16 {
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
//        default: return "Unknown"
        }
    }
}
