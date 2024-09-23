import Foundation

public struct NiftiV1Volume {
  
  private let voxels: [Voxel]
  
  public init(voxels: [Voxel]) {
    self.voxels = voxels
  }
}
