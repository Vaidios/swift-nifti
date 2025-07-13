import Foundation

protocol BinaryReader {
  var isByteSwapped: Bool { get }
  var data: Data { get }
}

extension BinaryReader {
  func readValue<T>(at offset: Int) throws(NiftiV1Error) -> T {
    do {
      return try data.load(at: offset, isByteSwapped: isByteSwapped)
    } catch {
      throw NiftiV1Error.invalidDataAccess
    }
  }
  
  func readVector<T>(at offset: Int, length: Int) throws(NiftiV1Error) -> [T] {
    do {
      return try data.loadVector(at: offset, length: length, isByteSwapped: isByteSwapped)
    } catch {
      throw NiftiV1Error.invalidDataAccess
    }
  }
}
