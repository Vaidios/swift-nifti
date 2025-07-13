import Foundation

extension Data {
  
  var byteSwapped: Data { Data(reversed()) }
  
  func loadVector<T>(at offset: Int = 0, length: Int, isByteSwapped: Bool) throws -> [T] {
    guard offset + length * MemoryLayout<T>.size <= count else {
      throw NiftiV1Error.invalidDataAccess
    }
    return try (0 ..< length).map { try load(at: offset + $0 * MemoryLayout<T>.size, isByteSwapped: isByteSwapped) }
  }
  
  func load<T>(at offset: Int, isByteSwapped: Bool = false) throws -> T {
    guard offset + MemoryLayout<T>.size <= count else {
      throw NiftiV1Error.invalidDataAccess
    }
    let subdata = subdata(in: offset ..< offset + MemoryLayout<T>.size)
    return isByteSwapped ? subdata.byteSwapped.load() : subdata.load()
  }
  
  func load<T>() -> T {
    withUnsafeBytes { $0.load(as: T.self) }
  }
}
