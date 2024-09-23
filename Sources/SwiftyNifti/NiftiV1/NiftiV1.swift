import Foundation

public struct NiftiV1 {
  
  public let url: URL
  
  public init(url: URL) throws {
    self.url = url
  }
  
  public func header() throws -> NiftiV1.Header {
    let headerBytes = try FileHandle.readHeaderBytes(from: url)
    let niftiBinReader = NiftiV1BinaryReader(data: headerBytes)
    return try niftiBinReader.getHeader()
  }
}
