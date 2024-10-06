import Foundation

public struct Voxel: Equatable {
  
  public let value: Double
  
  init(value: Double) {
    self.value = value
  }
  
  init(_ uint8: UInt8) {
    self.value = Double(uint8)
  }
}
