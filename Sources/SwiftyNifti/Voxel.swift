import Foundation

public struct Voxel: Equatable {
  
  public let value: Float
  
  init(value: Float) {
    self.value = value
  }
  
  init(_ uint8: UInt8) {
    self.value = Float(uint8)
  }
}
