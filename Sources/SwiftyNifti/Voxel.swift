import Foundation

public struct Voxel: Equatable {
  
  public let value: Double
  
  init(value: Double) {
    self.value = value
  }
  
  init(_ uint8: UInt8) {
    self.value = Double(uint8)
  }
  
  public var pixel: PixelData {
    PixelData(
      a: 255,
      r: UInt8(value),
      g: UInt8(value),
      b: UInt8(value)
    )
  }
}
