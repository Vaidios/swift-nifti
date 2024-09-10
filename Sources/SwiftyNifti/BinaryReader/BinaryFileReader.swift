//
//  BinaryFileReader.swift
//  SwiftyNifti
//
//  Created by Kamil Sosna on 02/12/2020.
//

import Foundation

class BinaryReader {
    
    var isByteSwapped: Bool = false
    
    private let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func readValue<Type>(at offset: Int) -> Type {
        let size = MemoryLayout<Type>.size
        
        let subdata = self.data.subdata(in: offset ..< offset + size)
        
        var dataToCast: Data
        if isByteSwapped {
            dataToCast = byteSwap(subdata)
        } else {
            dataToCast = subdata
        }
        
        let val = dataToCast.withUnsafeBytes { (ptr) -> Type in
            ptr.load(as: Type.self)
        }
        return val
    }
    
    func readVector<Type>(at offset: Int, length: Int) -> [Type] {
        var values = [Type]()
        let size = MemoryLayout<Type>.size
        values.reserveCapacity(length)
        for i in 0 ..< length {
            let value: Type = readValue(at: offset + i * size)
            values.append(value)
        }
        return values
    }
    
    private func byteSwap(_ data: Data) -> Data {
        return Data(data.reversed())
    }
}
    
