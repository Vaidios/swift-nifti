import Foundation

extension Data {
  
  var byteSwapped: Data { Data(reversed()) }
  
  func loadVector<T>(at offset: Int, length: Int, isByteSwapped: Bool) -> [T] {
    (0 ..< length).map { load(at: offset + $0 * MemoryLayout<T>.size, isByteSwapped: isByteSwapped) }
  }
  
  func load<T>(at offset: Int, isByteSwapped: Bool = false) -> T {
    let count = count
    let size = MemoryLayout<T>.size
    let subdata = subdata(in: offset ..< offset + size)
    return isByteSwapped ? subdata.byteSwapped.load() : subdata.load()
  }
  
  func load<T>() -> T {
    withUnsafeBytes { $0.load(as: T.self) }
  }
}
