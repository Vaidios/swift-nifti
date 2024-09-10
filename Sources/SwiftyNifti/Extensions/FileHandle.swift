//
//  FileHandle.swift
//  SwiftyNifti
//
//  Created by Kamil Sosna on 03/12/2020.
//

import Foundation

public extension FileHandle {
    static func readHeaderBytes(from url: URL) -> Data? {
        do {
            let handle = try FileHandle(forReadingFrom: url)
            let headerData = handle.readData(ofLength: 348)
            return headerData
        } catch {
            print(error)
            return nil
        }
    }
    static func readDataBytes(from url: URL, start: UInt64, end: UInt64) -> Data? {
        do {
            let handle = try FileHandle(forReadingFrom: url)
//            let data = handle.availableData
            handle.seek(toFileOffset: start)
            return handle.readData(ofLength: Int(end - start))
        } catch {
            print(error)
            return nil
        }
    }
}
