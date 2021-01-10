//
//  NiftiBinaryReader.swift
//  SwiftyNifti
//
//  Created by Kamil Sosna on 03/12/2020.
//

import Foundation

protocol NiftiBinaryReader: class {
    var isByteSwapped: Bool { get set }
    
    var data: Data! { get set }
    
    func readValue<Type>(at offset: Int) -> Type
    func readVector<Type>(at offset: Int, length: Int) -> [Type]
}
enum NiftiError: Swift.Error {
    case invalidHeaderSize(Int)
}
extension NiftiBinaryReader {

    var isDefaultEndian: Bool {
        
        return true
    }
    func getNiftiV1HeaderInfo() throws -> NiftiHeaderV1 {
        
        let hdr = NiftiHeaderV1()
        
        //Checking endianess
        var sizeOfHdr: Int32 = readValue(at: 0)
        if sizeOfHdr != 348 {
            isByteSwapped = true
            sizeOfHdr = readValue(at: 0)
        }
        
        if sizeOfHdr != 348 {
            throw NiftiError.invalidHeaderSize(Int(sizeOfHdr))
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
    
    
    func readSpacialData<T>(using nim: NiftiHeaderV1, into arr: inout [[[T]]], from newData: Data? = nil) {
      
        if newData != nil { self.data = newData }

        print("Memory layout \(MemoryLayout<T>.size)")
        var count: Int = 0
        for z in 0 ..< nim.nz {
            for y in 0 ..< nim.ny {
                for x in 0 ..< nim.nx {
                    let seekVal = Int(nim.vox_offset) + (count * nim.bytesPerVoxel)
//                    print(seekVal)
                    let val: T = readValue(at: seekVal)
//                    print(val)
                    arr[x][y][z] = val
                    count += 1
                }
            }
        }
    }
    
    func getPixelData(using nim: NiftiHeaderV1,
                      from newData: Data? = nil) throws -> [[[PixelData]]] {
        if newData != nil { self.data = newData }
        
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
                        throw SwiftyNifti.Error.invalidStringPath
                    }
                    count += 1
                }
            }
        }
        return arr
    }
}

public struct PixelData {
    var a: UInt8
    var r: UInt8
    var g: UInt8
    var b: UInt8
    
    init(a: UInt8 = 255, r: UInt8, g: UInt8, b: UInt8) {
        self.a = a
        self.r = r
        self.g = g
        self.b = b
    }
}
//public func loadBricks() -> NiftiSpacialData {
//    var nim = self.header
//    print(nim)
//    updateDimsFromArray(nim: &nim)
//    print(nim)
//    var spacialData = NiftiSpacialData(nx: nim.nx, ny: nim.ny, nz: nim.nz, size: nim.bytesPerVoxel)
//
//    print("Spacial data size: \(spacialData.data.count) \(spacialData.data[0].count) \(spacialData.data[0][0].count)")
//    let availableData = fileHandle.availableData.count
//    print("Size of data: \(availableData)")
//    print("Calculated file length - \(nim.fileLength)")
//    print("Diff - \(nim.fileLength - availableData)")
//    let binReader = BinaryReader(fileHandle.availableData.subdata(in: Int(nim.vox_offset) ..< nim.fileLength))
//    for z in 0 ..< nim.nz {
//        for y in 0 ..< nim.ny {
//            for x in 0 ..< nim.nx {
//                spacialData.data[x][y][z] = binReader.readData(with: nim.bytesPerVoxel)
//            }
//        }
//    }
////        print("Data read at first point \(spacialData.data[0][0][0].withUnsafeBytes { ptr -> UInt8 in ptr.load(as: UInt8.self) }), last point \(spacialData.data.last!.last!.last!.withUnsafeBytes { ptr -> UInt8 in ptr.load(as: UInt8.self) })")
//    //Only one space for now
//    return spacialData
//
//}


//func getNiftiV1HeaderInfo(from data: Data) throws -> NiftiHeaderV1 {
//
//    let hdr = NiftiHeaderV1()
//
//    //Checking endianess
//    let sizeOfHdr: Int32
//    if isDefaultEndian {
//        sizeOfHdr = readValue(at: 0)
//    } else {
//        isByteSwapped = true
//        sizeOfHdr = readValue(at: 0)
//    }
//    if sizeOfHdr != 348 {
//        throw NiftiError.invalidHeaderSize(Int(sizeOfHdr))
//    }
//
//    ///Byte offset - 39 dim_info
//    let dim_info: UInt8 = readValue(at: 39)
//    ///Byte offset - 40 - dimensions
//    let dim: [Int16] = readVector(at: 40, length: 8)
//    ///Byte offset - 56 - intent_p1
//    let intent_p1: Float = readValue(at: 58)
//    ///Byte offset - 60 - intent_p2
//    let intent_p2: Float = readValue(at: 60)
//    ///Byte offset - 64 - intent_p3
//    let intent_p3: Float = readValue(at: 64)
//
//    ///Byte offset - 68 - Intent code
//    let intent_code: Int16 = readValue(at: 68)
//    //////Byte offset - 70 - Data type
//    let datatype: Int16 = readValue(at: 70)
//    ///Byte offset - 72 - Bit pix
//    let bitpix: Int16 = readValue(at: 72)
//    //////Byte offset - 74 - slice_start
//    let slice_start: Int16 = readValue(at: 74)
//
//    ///Byte offset - 76 - pixdim
//    let pixdim: [Float] = readVector(at: 76, length: 8)
//
//    ///Byte offset - 108 - vox_offset
//    let vox_offset: Float = readValue(at: 108)
//
//    ///Byte offset - 112 - scl_slope
//    let scl_slope: Float = readValue(at: 112)
//    ///Byte offset - 116 - scl_inter
//    let scl_inter: Float = readValue(at: 116)
//    ///Byte offset - 120 - slice_end
//    let slice_end: Int16 = readValue(at: 120)
//    ///Byte offset - 122 - slice_code
//    let slice_code: UInt8 = readValue(at: 122)
//
//    ///Byte offset - 123 - xyzt_units
//    let xyzt_units: UInt8 = readValue(at: 123)
//
//    ///Byte offset - 124 - cal_max
//    let cal_max: Float = readValue(at: 124)
//    ///Byte offset - 128 - cal_min
//    let cal_min: Float = readValue(at: 128)
//
//    ///Byte offset - 132 - slice_duration
//    let slice_duration: Float = readValue(at: 132)
//    ///Byte offset - 136 - toffset
//    let toffset: Float = readValue(at: 136)
//
//    ///Byte offset - 140 - glmax int
//    let glmax: Int32 = readValue(at: 140)
//    ///Byte offset - 144 - glmin int
//    let glmin: Int32 = readValue(at: 144)
//
//    ///Byte offset - 148 - description [UInt8]
//    let descript: [UInt8] = readVector(at: 148, length: 80)
//    ///Byte offset - 228 - aux_file [UInt8]
//    let aux_file: [UInt8] = readVector(at: 228, length: 24)
//
//    ///Byte offset - 252 - qform_code
//    let qform_code: Int16 = readValue(at: 252)
//    ///Byte offset - 254 - sform_code
//    let sform_code: Int16 = readValue(at: 254)
//
//    ///Byte offset - 256 - quatern_b
//    let quatern_b: Float = readValue(at: 256)
//    ///Byte offset - 260 - quatern_c
//    let quatern_c: Float = readValue(at: 260)
//    ///Byte offset - 264 - quatern_d
//    let quatern_d: Float = readValue(at: 264)
//    ///Byte offset - 268 - qoffset_x
//    let qoffset_x: Float = readValue(at: 268)
//    ///Byte offset - 272 - qoffset_y
//    let qoffset_y: Float = readValue(at: 272)
//    ///Byte offset - 276 - qoffset_z
//    let qoffset_z: Float = readValue(at: 276)
//
//    ///Byte offset - 280 - srow_x
//    let srow_x: [Float] = readVector(at: 280, length: 4)
//    ///Byte offset - 296 - srow_y
//    let srow_y: [Float] = readVector(at: 296, length: 4)
//    ///Byte offset - 312 - srow_z
//    let srow_z: [Float] = readVector(at: 312, length: 4)
//
//    ///Byte offset - 328 - intent_name
//    let intent_name: [UInt8] = readVector(at: 328, length: 16)
//
//    ///Byte offset - 344 - magic
//    let magic: [UInt8] = readVector(at: 344, length: 4)
//
//    return hdr
//}


