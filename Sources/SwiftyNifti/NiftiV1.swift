import Foundation

public struct NiftiV1 {
  
  public let header: NiftiV1.Header
  
  let url: URL
  
  public init(url: URL) throws {
    self.url = url
    guard let fileBytes = FileHandle.readHeaderBytes(from: url) else {
      throw SwiftyNiftiError.invalidStringPath
    }
    let niftiBinReader = NiftiV1BinaryReader(data: fileBytes)
    
    self.header = try niftiBinReader.getHeader()
  }
}
