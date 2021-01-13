//
//  NiftiV1BinaryReader.swift
//  SwiftyNifti
//
//  Created by Kamil Sosna on 13/01/2021.
//

import Foundation

enum BinaryError: Swift.Error {
    case invalidHeaderSize
    case unsupportedDataFormat
}

class NiftiV1BinaryReader: BinaryReader {
    
    func getHeader() throws -> NiftiHeaderV1 {
        
        let hdr = NiftiHeaderV1()
        
        //Checking endianess
        var sizeOfHdr: Int32 = readValue(at: 0)
        if sizeOfHdr != 348 {
            isByteSwapped = true
            sizeOfHdr = readValue(at: 0)
        }
        
        if sizeOfHdr != 348 {
            throw BinaryError.invalidHeaderSize
        }
        
        hdr.sizeof_hdr = sizeOfHdr
        ///Byte offset - 39 dim_info
        hdr.dim_info = readValue(at: 39)
        ///Byte offset - 40 - dimensions
        hdr.dim = readVector(at: 40, length: 8)
        updateDimsFromArray(dims: &hdr.dim)
        ///Byte offset - 56 - intent_p1
        hdr.intent_p1 = readValue(at: 58)
        ///Byte offset - 60 - intent_p2
        hdr.intent_p2 = readValue(at: 60)
        ///Byte offset - 64 - intent_p3
        hdr.intent_p3 = readValue(at: 64)

        ///Byte offset - 68 - Intent code
        hdr.intent_code = readValue(at: 68)
        //////Byte offset - 70 - Data type
        hdr.datatype = readValue(at: 70)
        ///Byte offset - 72 - Bit pix
        hdr.bitpix = readValue(at: 72)
        //////Byte offset - 74 - slice_start
        hdr.slice_start = readValue(at: 74)

        ///Byte offset - 76 - pixdim
        hdr.pixdim = readVector(at: 76, length: 8)
        
        ///Byte offset - 108 - vox_offset
        hdr.vox_offset = readValue(at: 108)
        
        ///Byte offset - 112 - scl_slope
        hdr.scl_slope = readValue(at: 112)
        ///Byte offset - 116 - scl_inter
        hdr.scl_inter = readValue(at: 116)
        ///Byte offset - 120 - slice_end
        hdr.slice_end = readValue(at: 120)
        ///Byte offset - 122 - slice_code
        hdr.slice_code = readValue(at: 122)
        
        ///Byte offset - 123 - xyzt_units
        hdr.xyzt_units = readValue(at: 123)
        
        ///Byte offset - 124 - cal_max
        hdr.cal_max = readValue(at: 124)
        ///Byte offset - 128 - cal_min
        hdr.cal_min = readValue(at: 128)
        
        ///Byte offset - 132 - slice_duration
        hdr.slice_duration = readValue(at: 132)
        ///Byte offset - 136 - toffset
        hdr.toffset = readValue(at: 136)
        
        ///Byte offset - 140 - glmax int
        hdr.glmax = readValue(at: 140)
        ///Byte offset - 144 - glmin int
        hdr.glmin = readValue(at: 144)
        
        ///Byte offset - 148 - description [UInt8]
        hdr.descript = readVector(at: 148, length: 80)
        ///Byte offset - 228 - aux_file [UInt8]
        hdr.aux_file = readVector(at: 228, length: 24)
        
        ///Byte offset - 252 - qform_code
        hdr.qform_code = readValue(at: 252)
        ///Byte offset - 254 - sform_code
        hdr.sform_code = readValue(at: 254)
        
        ///Byte offset - 256 - quatern_b
        hdr.quatern_b = readValue(at: 256)
        ///Byte offset - 260 - quatern_c
        hdr.quatern_c = readValue(at: 260)
        ///Byte offset - 264 - quatern_d
        hdr.quatern_d = readValue(at: 264)
        ///Byte offset - 268 - qoffset_x
        hdr.qoffset_x = readValue(at: 268)
        ///Byte offset - 272 - qoffset_y
        hdr.qoffset_y = readValue(at: 272)
        ///Byte offset - 276 - qoffset_z
        hdr.qoffset_z = readValue(at: 276)
        
        ///Byte offset - 280 - srow_x
        hdr.srow_x = readVector(at: 280, length: 4)
        ///Byte offset - 296 - srow_y
        hdr.srow_y = readVector(at: 296, length: 4)
        ///Byte offset - 312 - srow_z
        hdr.srow_z = readVector(at: 312, length: 4)
        
        ///Byte offset - 328 - intent_name
        hdr.intent_name = readVector(at: 328, length: 16)
        
        ///Byte offset - 344 - magic
        hdr.magic = readVector(at: 344, length: 4)
        
        return hdr
    }
    
    func updateDimsFromArray(dims: inout [Int16]) {
        var nDim: Int
        
        if dims[0] < 1 || dims[0] > 7 {
            print("Invalid dimensions")
            for (idx, size) in dims.enumerated() { print("Dim \(idx) has size of \(size)") }
            return
        }
        
        if dims[1] < 1 { dims[1] = 1 }
        if dims[0] < 2 || (dims[0] >= 2 && dims[2] < 1) { dims[2] = 1 }
        if dims[0] < 3 || (dims[0] >= 3 && dims[3] < 1) { dims[3] = 1 }
        if dims[0] < 4 || (dims[0] >= 4 && dims[4] < 1) { dims[4] = 1 }
        if dims[0] < 5 || (dims[0] >= 5 && dims[5] < 1) { dims[5] = 1 }
        if dims[0] < 6 || (dims[0] >= 6 && dims[6] < 1) { dims[6] = 1 }
        if dims[0] < 7 || (dims[0] >= 7 && dims[7] < 1) { dims[7] = 1 }
        
        nDim = Int(dims[0])
        for _ in dims.reversed() {
            
            if nDim > 1 && (dims[nDim] <= 1) {
                nDim -= 1
            } else { break }
        }
        dims[0] = Int16(nDim)
    }
    
    func getPixelData(using nim: NiftiHeaderV1,
                      from newData: Data? = nil) throws -> [[[PixelData]]] {
        
        var arr = [[[PixelData]]].init(
            repeating: [[PixelData]].init(
                repeating: [PixelData].init(
                    repeating: PixelData(r: 0, g: 0, b: 0), count: nim.nz), count: nim.ny), count: nim.nx)
        
        var count: Int = 0
        for z in 0 ..< nim.nz {
            for y in 0 ..< nim.ny {
                for x in 0 ..< nim.nx {
                    let seekVal = Int(nim.vox_offset) + (count * nim.bytesPerVoxel)
                    switch nim.niftiDatatype {
                    case .uint8:
                        let val: UInt8 = readValue(at: seekVal)
                        arr[x][y][z].r = val
                        arr[x][y][z].g = val
                        arr[x][y][z].b = val
                        
                    default:
                        throw BinaryError.unsupportedDataFormat
                    }
                    count += 1
                }
            }
        }
        return arr
    }
}
