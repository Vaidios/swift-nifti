import Foundation

extension Data {
  
  var byteSwapped: Data { Data(reversed()) }

  func loadVector<T>(at offset: Int = 0, length: Int, isByteSwapped: Bool) -> [T] {
    (0 ..< length).map { load(at: offset + $0 * MemoryLayout<T>.size, isByteSwapped: isByteSwapped) }
  }

  func load<T>(at offset: Int, isByteSwapped: Bool = false) -> T {
    let end = offset + MemoryLayout<T>.size
    precondition(end <= count, "Read out of bounds offset \(offset) size \(MemoryLayout<T>.size) count \(count)")
    var buffer = [UInt8](repeating: 0, count: MemoryLayout<T>.size)
    copyBytes(to: &buffer, from: offset ..< end)
    if isByteSwapped { buffer.reverse() }
    return buffer.withUnsafeBytes { $0.loadUnaligned(as: T.self) }
  }

  func load<T>() -> T {
    withUnsafeBytes { $0.loadUnaligned(as: T.self) }
  }
}
