import Foundation

public struct Voxel: Equatable {
  public let a: UInt8
  public let r: UInt8
  public let g: UInt8
  public let b: UInt8
  
  init(value: UInt8 = 0) {
    self.a = 255
    self.r = value
    self.g = value
    self.b = value
  }
}
