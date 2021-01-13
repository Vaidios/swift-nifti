//
//  PixelData.swift
//  SwiftyNifti
//
//  Created by Kamil Sosna on 13/01/2021.
//

import Foundation

public struct PixelData {
    
    public var a: UInt8
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    
    public init(a: UInt8 = 255, r: UInt8, g: UInt8, b: UInt8) {
        self.a = a
        self.r = r
        self.g = g
        self.b = b
    }
}
