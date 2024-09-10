import Foundation

class BinaryReader {
  
  var isByteSwapped: Bool = false
  
  private let data: Data
  
  init(data: Data) {
    self.data = data
  }
  
  func readValue<T>(at offset: Int) -> T {
    let size = MemoryLayout<T>.size
    let subdata = self.data.subdata(in: offset ..< offset + size)
    let dataToCast = isByteSwapped ? byteSwap(subdata) : subdata
    return dataToCast.withUnsafeBytes { $0.load(as: T.self) }
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
