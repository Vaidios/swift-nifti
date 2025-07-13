import Foundation

public enum PlaneDirection {
    case axial // xy plane at a fixed z
    case coronal // xz plane at a fixed y
    case sagittal // yz plane at a fixed x
}

/// Dimensions of a 3D volume (nx, ny, nz)
public struct VolumeDimensions {
  public let nx: Int
  public let ny: Int
  public let nz: Int
}

/// Represents a 3D NIfTI volume (voxel data and dimensions).
public struct NiftiV1Volume {
  /// The dimensions of the volume (nx, ny, nz)
  public let dimensions: VolumeDimensions
  /// The voxels in the volume, in row-major order
  public let voxels: [Voxel]

  /// Create a new volume with the given dimensions and voxels.
  public init(dimensions: VolumeDimensions, voxels: [Voxel]) {
    self.dimensions = dimensions
    self.voxels = voxels
  }

  /// Get the maximum valid index for a given plane direction.
  public func getMaxValue(of plane: PlaneDirection) -> Int {
    switch plane {
    case .axial: return dimensions.nz
    case .coronal: return dimensions.ny
    case .sagittal: return dimensions.nx
    }
  }

  /// Extract a 2D plane from the 3D volume.
  /// - Parameters:
  ///   - plane: The plane direction (axial, coronal, sagittal)
  ///   - sliceIndex: The index of the slice to extract
  /// - Returns: The extracted plane, or nil if the index is out of bounds
  public func extractPlane(plane: PlaneDirection, sliceIndex: Int) -> Plane? {
    let volume = self.voxels
    var result: [Voxel] = []
    let width = dimensions.nx
    let height = dimensions.ny
    let depth = dimensions.nz
    switch plane {
    case .axial:
      guard sliceIndex >= 0 && sliceIndex < getMaxValue(of: plane) else { return nil }
      for y in 0..<height {
        for x in 0..<width {
          let index = x + y * width + sliceIndex * width * height
          result.append(volume[index])
        }
      }
      return Plane(data: result, width: width, height: height)
    case .coronal:
      guard sliceIndex >= 0 && sliceIndex < getMaxValue(of: plane) else { return nil }
      for z in 0..<depth {
        for x in 0..<width {
          let index = x + sliceIndex * width + z * width * height
          result.append(volume[index])
        }
      }
      return Plane(data: result, width: width, height: depth)
    case .sagittal:
      guard sliceIndex >= 0 && sliceIndex < getMaxValue(of: plane) else { return nil }
      for z in 0..<depth {
        for y in 0..<height {
          let index = sliceIndex + (y * width) + (z * width * height)
          result.append(volume[index])
        }
      }
      return Plane(data: result, width: height, height: depth)
    }
  }
}

/// A 2D plane extracted from a 3D volume.
public struct Plane {
  /// The voxel data for the plane
  public let data: [Voxel]
  /// The width of the plane
  public let width: Int
  /// The height of the plane
  public let height: Int
  public init(data: [Voxel], width: Int, height: Int) {
    self.data = data
    self.width = width
    self.height = height
  }
}
