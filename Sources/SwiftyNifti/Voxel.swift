import Foundation

public struct Voxel: Equatable {
  
  public let value: Float
  
  init(value: Float) {
    self.value = value
  }
  
  init(_ uint8: UInt8) {
    self.value = Float(uint8)
  }
  
  public var pixel: PixelData {
    let clampedValue = max(0, min(255, value))
    return PixelData(
      a: 255,
      r: UInt8(clampedValue),
      g: UInt8(clampedValue),
      b: UInt8(clampedValue)
    )
  }
}
