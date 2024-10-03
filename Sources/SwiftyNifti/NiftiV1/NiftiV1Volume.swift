import Foundation

public struct NiftiV1Volume {
  
  public let header: NiftiV1.Header
  public let voxels: [Voxel]
  
  init(header: NiftiV1.Header, voxels: [Voxel]) {
    self.header = header
    self.voxels = voxels
  }
  
  /// Getting a plane from available volume
  /// - Parameter z: Indexing from 0
  /// - Returns: Returns an array of voxels for a coronal plane
  public func getCoronalPlane(z: Int) -> [Voxel] {
    let nx = header.nx
    let ny = header.ny
    let z = z + 1
    var parsedVoxels = [Voxel](repeating: Voxel(value: 0), count: nx * ny)
    for x in 1...nx {
      for y in 1...ny {
        let voxelIndex = (x * y * z) - 1
        guard voxelIndex < self.voxels.count else { continue }
        let voxel = self.voxels[voxelIndex]
        parsedVoxels[(x * y) - 1] = voxel
      }
    }
    return parsedVoxels
  }
}
