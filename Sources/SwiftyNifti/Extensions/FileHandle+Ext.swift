import Foundation

public extension FileHandle {
  
  static func readHeaderBytes(from url: URL) throws -> Data {
    try FileHandle(forReadingFrom: url).readData(ofLength: 348)
  }
  
  static func readDataBytes(from url: URL, start: UInt64, end: UInt64) -> Data? {
    do {
      let handle = try FileHandle(forReadingFrom: url)
      handle.seek(toFileOffset: start)
      return handle.readData(ofLength: Int(end - start))
    } catch {
      print(error)
      return nil
    }
  }
}
