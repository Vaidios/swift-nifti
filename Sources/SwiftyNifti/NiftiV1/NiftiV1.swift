import Foundation

public struct NiftiV1 {
  
  public let header: NiftiV1.Header
  
  let url: URL
  
  public init(url: URL) throws {
    self.url = url
    let headerBytes = try FileHandle.readHeaderBytes(from: url)
    let niftiBinReader = NiftiV1BinaryReader(data: headerBytes)
    self.header = try niftiBinReader.getHeader()
  }
}
