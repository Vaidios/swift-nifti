import Foundation

/// Represents a single voxel (volume pixel) in a NIfTI volume.
public struct Voxel: Equatable {
  /// The value of the voxel (normalized to [0, 255] for display)
  public let value: Float
  /// Create a voxel from a value
  public init(value: Float) {
    self.value = value
  }
  /// Create a voxel from a UInt8 value
  public init(_ uint8: UInt8) {
    self.value = Float(uint8)
  }
  /// Convert the voxel to grayscale pixel data (for image display)
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
