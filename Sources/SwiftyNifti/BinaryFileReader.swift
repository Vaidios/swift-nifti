import Foundation

protocol BinaryReader {
  var isByteSwapped: Bool { get }
  var data: Data { get }
}

extension BinaryReader {
  func readValue<T>(at offset: Int) -> T {
    data.load(at: offset, isByteSwapped: isByteSwapped)
  }
  
  func readVector<T>(at offset: Int, length: Int) -> [T] {
    data.loadVector(at: offset, length: length, isByteSwapped: isByteSwapped)
  }
}
