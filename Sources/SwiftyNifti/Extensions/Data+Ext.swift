import Foundation

extension Data {
  
  var byteSwapped: Data { Data(reversed()) }
  
  func loadVector<T>(at offset: Int = 0, length: Int, isByteSwapped: Bool) -> [T] {
    guard offset + length * MemoryLayout<T>.size <= count else {
      fatalError("Vector data access out of bounds")
    }
    return (0 ..< length).map { load(at: offset + $0 * MemoryLayout<T>.size, isByteSwapped: isByteSwapped) }
  }
  
  func load<T>(at offset: Int, isByteSwapped: Bool = false) -> T {
    guard offset + MemoryLayout<T>.size <= count else {
      fatalError("Data access out of bounds")
    }
    let subdata = subdata(in: offset ..< offset + MemoryLayout<T>.size)
    return isByteSwapped ? subdata.byteSwapped.load() : subdata.load()
  }
  
  func load<T>() -> T {
    withUnsafeBytes { $0.load(as: T.self) }
  }
}
