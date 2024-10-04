import Foundation

public enum PlaneDirection {
    case axial // xy plane at a fixed z
    case coronal // xz plane at a fixed y
    case sagittal // yz plane at a fixed x
}

public struct VolumeDimensions {
  let nx: Int
  let ny: Int
  let nz: Int
}

public struct NiftiV1Volume {
  
  public let dimensions: VolumeDimensions
  public let voxels: [Voxel]
  
  init(dimensions: VolumeDimensions, voxels: [Voxel]) {
    self.dimensions = dimensions
    self.voxels = voxels
  }
  
  public func getMaxValue(of plane: PlaneDirection) -> Int {
    switch plane {
    case .axial: dimensions.nz
    case .coronal: dimensions.ny
    case .sagittal: dimensions.nx
    }
  }

  // Function to extract a 2D plane from a 3D volume
  public func extractPlane(plane: PlaneDirection, sliceIndex: Int) -> Plane? {
    let volume = self.voxels
    var result: [Voxel] = []
    
    let width = dimensions.nx
    let height = dimensions.ny
    let depth = dimensions.nz
    
    switch plane {
    case .axial:
      // Extract xy plane for a given z (sliceIndex)
      guard sliceIndex >= 0 && sliceIndex < getMaxValue(of: plane) else { return nil }
      for y in 0..<height {
        for x in 0..<width {
          let index = x + y * width + sliceIndex * width * height
          result.append(volume[index])
        }
      }
      
    case .coronal:
      // Extract xz plane for a given y (sliceIndex)
      guard sliceIndex >= 0 && sliceIndex < getMaxValue(of: plane) else { return nil }
      for z in 0..<depth {
        for x in 0..<width {
          let index = x + sliceIndex * width + z * width * height
          result.append(volume[index])
        }
      }
      
    case .sagittal:
      // Extract yz plane for a given x (sliceIndex)
      guard sliceIndex >= 0 && sliceIndex < getMaxValue(of: plane) else { return nil }
      for z in 0..<depth {
        for y in 0..<height {
          let index = sliceIndex + (y * width) + (z * width * height)
          result.append(volume[index])
        }
      }
    }
    
    switch plane {
    case .axial:
      return Plane(data: result, width: width, height: height)
    case .coronal:
      return Plane(data: result, width: width, height: depth)
    case .sagittal:
      return Plane(data: result, width: depth, height: height)
    }
  }
}

public struct Plane {
  public let data: [Voxel]
  public let width: Int
  public let height: Int
  
  init(data: [Voxel], width: Int, height: Int) {
    self.data = data
    self.width = width
    self.height = height
  }
}
